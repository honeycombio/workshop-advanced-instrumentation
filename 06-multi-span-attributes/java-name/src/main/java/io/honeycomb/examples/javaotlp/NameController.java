package io.honeycomb.examples.javaotlp;

import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.baggage.Baggage;
import io.opentelemetry.api.common.AttributeKey;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.trace.*;
import io.opentelemetry.context.Context;
import io.opentelemetry.context.Scope;
import io.opentelemetry.extension.annotations.WithSpan;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.*;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.client.RestTemplate;

@RestController
public class NameController {

	private static final Map<Integer, List<String>> NAMES_BY_YEAR = Map.of(
		2015, Arrays.asList("sophia", "jackson", "emma", "aiden", "olivia", "liam", "ava", "lucas", "mia", "noah"),
		2016, Arrays.asList("sophia", "jackson", "emma", "aiden", "olivia", "lucas", "ava", "liam", "mia", "noah"),
		2017, Arrays.asList("sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "lucas"),
		2018, Arrays.asList("sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "caden"),
		2019, Arrays.asList("sophia", "liam", "olivia", "jackson", "emma", "noah", "ava", "aiden", "aria", "grayson"),
		2020, Arrays.asList("olivia", "noah", "emma", "liam", "ava", "elijah", "isabella", "oliver", "sophia", "lucas")
	);

	private static final Random generator = new Random();

	@RequestMapping("/name")
	public String index(@RequestParam(name = "guess", required = false) String guess) {

		doSomething();
		addMultiSpanAttribute("name_guess", guess);

		try {
			Thread.sleep(generator.nextInt(250));
			int year = getYear();
			Thread.sleep(generator.nextInt(150) + 100);
			List<String> names = NAMES_BY_YEAR.get(year);
			if (names == null) {
				return "";
			}
			String name = names.get(generator.nextInt(names.size() - 1));

			Span.current().setAttribute("name_returned", name);

			if (name.equals(guess)) {
				Span.current().setAttribute("name_match", true);
				return "WOW!!! You guessed the right name: " + name;
			} else {
				return name;
			}
		} catch (InterruptedException e) {
			Span.current().setStatus(StatusCode.ERROR);
		}
		return "";
	}

	private int getYear() {
		final String uri = "http://localhost:6001/year";
		RestTemplate restTemplate = new RestTemplate();
		String result = restTemplate.getForObject(uri, String.class);
		if (result == null || result.isEmpty()) {
			return 0;
		}
		return Integer.parseInt(result);
	}

	@WithSpan("doing-something")
	private void doSomething() {
		Span.current().setAttribute("otel", "rocks");
		try {
			Thread.sleep(generator.nextInt(250));
		} catch (InterruptedException e) {
			Span.current().setStatus(StatusCode.ERROR);
		}
	}

	public static void addMultiSpanAttribute(String key, String value) {
		Span.current().setAttribute(key, value);
		Baggage.current()
				.toBuilder()
				.put(key, value)
				.build()
				.makeCurrent();
	}

}
