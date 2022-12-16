package io.honeycomb.examples.javaotlp;

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
			e.printStackTrace();
		}
		return getYear();
	}

	public String getYear() {
		int rnd = generator.nextInt(YEARS.length);
		try {
			Thread.sleep(generator.nextInt(250));
		} catch (InterruptedException e) {
			e.printStackTrace();
		}		
		return YEARS[rnd];
	}


}
