package io.honeycomb.examples.javaotlp;

import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.common.AttributeKey;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.trace.*;
import io.opentelemetry.context.Context;
import io.opentelemetry.context.Scope;
import io.opentelemetry.extension.annotations.WithSpan;
import org.springframework.web.bind.annotation.RestController;
import java.util.Random;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
public class YearController {

	private static final String[] YEARS = new String[]{"2015", "2016", "2017", "2018", "2019", "2020"};
	private static final Random generator = new Random();

	@RequestMapping("/year")
	public String index() {
		try {
			Thread.sleep(generator.nextInt(250));
		} catch (InterruptedException e) {
			Span.current().setStatus(StatusCode.ERROR);;
		}
			
		Span.current().setAttribute("foo", "bar");

		Runnable runnable = () -> { doSomeWork(); };
		new Thread(Context.current().wrap(runnable)).start();

		return getRandomYear();
	}

	@WithSpan("random-year")
	public String getRandomYear() {
		int rnd = generator.nextInt(YEARS.length);
		Span.current().setAttribute("random-index", rnd);
		
		try {
			Thread.sleep(generator.nextInt(250));
		} catch (InterruptedException e) {
			Span.current().setStatus(StatusCode.ERROR);;
		}		
		return YEARS[rnd];
	}

	public void doSomeWork() {
		Tracer tracer = GlobalOpenTelemetry.getTracer("");

		Span span = tracer.spanBuilder("some-work").startSpan();
		try (Scope scope = span.makeCurrent()) {
			span.setAttribute("otel", "rocks");
			Thread.sleep(generator.nextInt(250));
			span.addEvent("my event", Attributes.of(AttributeKey.stringKey("more"), "details"));
			Thread.sleep(generator.nextInt(150) + 100);
			span.addEvent("another event");

			Runnable runnable = () -> { generateLinkedTrace(); };
			new Thread(Context.current().wrap(runnable)).start();

		} catch (Throwable t) {
			span.setStatus(StatusCode.ERROR);
		} finally {
			span.end();
		}

	}

	private void generateLinkedTrace() {
		SpanContext linkedContext = Span.current().getSpanContext();


		Tracer tracer = GlobalOpenTelemetry.getTracer("");

		Span span = tracer.spanBuilder("generated-span")
				.setNoParent()
				.addLink(linkedContext)
				.setAttribute("depth", 1)
				.startSpan();
		span.makeCurrent();

		try {
			Thread.sleep(250);
			addRecursiveSpan(2, 5);
		} catch (InterruptedException e) {
			span.setStatus(StatusCode.ERROR);;
		}

		span.end();
	}

	private void addRecursiveSpan(int depth, int maxDepth) throws InterruptedException {
		Tracer tracer = GlobalOpenTelemetry.getTracer("");

		Span span = tracer.spanBuilder("generated-span")
				.setAttribute("depth", depth)
				.startSpan();
		span.makeCurrent();

		Thread.sleep(generator.nextInt(250));
		if (depth  < maxDepth) {
			addRecursiveSpan(depth + 1, maxDepth);
		}

		span.end();
	}




}
