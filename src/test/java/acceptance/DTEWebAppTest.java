package acceptance;// src/test/java/GoogleSearchTest.java

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import java.net.MalformedURLException;

public class DTEWebAppTest {
    public WebDriver driver;

    public static String browser = System.getenv("BROWSER");
    public static String environment = System.getenv("ENV");
    public static String tempRoute = System.getenv("TEMP_ROUTE");
    public static String local = System.getenv("LOCAL");

    @BeforeClass(alwaysRun = true)
    //@Parameters({"os", "browser", "url", "node"})
    public void setUp() throws MalformedURLException {

        String url;

        if(environment.equalsIgnoreCase("local")){
            url = "http://localhost:8087/";
        } else {
            if (tempRoute != null && !tempRoute.isEmpty() && tempRoute.equalsIgnoreCase("temp")) {
                url = "http://dte-web-app-demo-" + environment + "-temp.cfapps.haas-202.pez.pivotal.io/";
            } else {
                url = "http://dte-web-app-demo-" + environment + ".cfapps.haas-202.pez.pivotal.io/";
            }
        }


        SetupTestDriver setupTestDriver = new SetupTestDriver("mac", browser, url);

        driver = setupTestDriver.getDriver();

    }

    @Test
    public void verifyHtmlTitle() {

        try {
            Thread.sleep(2*1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        Assert.assertEquals(driver.getTitle(),"Spring Boot Thymeleaf Hello World Example");
    }

    @Test
    public void verifyWelcomeStatement() {

        try {
            Thread.sleep(2*1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        String welcomeText = driver.findElement(By.id("welcome-statement")).getText();

        Assert.assertEquals(welcomeText,"Welcome DTE Energy Web app");
    }

    @AfterClass(alwaysRun = true)
    public void closeBrowser() {
        driver.quit();
    }

}
