package io.honeycomb.examples.javaotlp;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@RestController
public class YearController {

	private static final int[] YEARS = new int[]{2015, 2016, 2017, 2018, 2019, 2020};
	private static final Random generator = new Random();

	@RequestMapping(value="/", produces="text/html")
	public String index() {
		return "service: <a href='/year'>/year</a>";
	}

	@RequestMapping("/year")
	public Map<String, Object> year() {
		try {
			Thread.sleep(generator.nextInt(250));
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		Map<String, Object> response = new HashMap<>();
		response.put("language", "Java");
		response.put("year", getYear());

		return response;
	}

	public int getYear() {
		int rnd = generator.nextInt(YEARS.length);
		try {
			Thread.sleep(generator.nextInt(250));
		} catch (InterruptedException e) {
			e.printStackTrace();
		}		
		return YEARS[rnd];
	}
}
