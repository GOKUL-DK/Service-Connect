package com.serviceconnect.selenium;

import org.junit.jupiter.api.*;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.Keys;
import org.openqa.selenium.PageLoadStrategy;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;
import java.time.Duration;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class ServiceConnectTest {

    private static WebDriver driver;
    private static WebDriverWait wait;
    private static final String BASE_URL = System.getProperty("app.url", "http://localhost:8080/ServiceConnect");

    @BeforeAll
    public static void setUp() {
        System.setProperty("webdriver.chrome.silentOutput", "true");
        java.util.logging.Logger.getLogger("org.openqa.selenium").setLevel(java.util.logging.Level.OFF);

        ChromeOptions options = new ChromeOptions();
        boolean headless = Boolean.parseBoolean(System.getProperty("headless", "true"));
        if (headless) {
            options.addArguments("--headless=new");
        }
        options.addArguments("--remote-allow-origins=*");
        options.addArguments("--no-sandbox");
        options.addArguments("--disable-dev-shm-usage");
        options.addArguments("--disable-gpu");
        options.addArguments("--disable-extensions");
        options.addArguments("--disable-software-rasterizer");
        options.addArguments("--blink-settings=imagesEnabled=false");
        options.addArguments("--disk-cache-size=0");
        options.addArguments("--disable-background-networking");
        options.addArguments("--disable-default-apps");
        options.addArguments("--disable-sync");
        options.addArguments("--mute-audio");
        options.addArguments("--window-size=1920,1080");
        options.setPageLoadStrategy(PageLoadStrategy.EAGER);

        driver = new ChromeDriver(options);
        driver.manage().timeouts().implicitlyWait(Duration.ofMillis(200));
        wait = new WebDriverWait(driver, Duration.ofSeconds(8), Duration.ofMillis(50));

        // Ensure provider 101 (Arun Kumar) is AVAILABLE and 104 (Suresh Plumber) is
        // BUSY
        try {
            com.serviceconnect.dao.ProviderDAO pDao = new com.serviceconnect.dao.ProviderDAO();
            pDao.updateStatus(101, "AVAILABLE");
            pDao.updateStatus(104, "BUSY");
        } catch (Exception ignored) {
        }
    }

    @AfterAll
    public static void tearDown() {
        if (driver != null) {
            driver.quit();
        }
    }

    @Test
    @Order(1)
    public void test01_OpenApplication() {
        driver.get(BASE_URL + "/index.jsp");

        WebElement brand = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.xpath("//a[contains(@class,'nav-brand')]//span[contains(text(),'ServiceConnect')]")));
        assertNotNull(brand, "ServiceConnect brand title should be visible");
        assertTrue(driver.getTitle().contains("ServiceConnect"), "Page title should contain ServiceConnect");
    }

    @Test
    @Order(2)
    public void test02_CustomerLogin() {
        driver.get(BASE_URL + "/login.jsp");

        WebElement usernameInput = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.xpath("//input[@name='username']")));
        WebElement passwordInput = driver.findElement(By.xpath("//input[@name='password']"));
        WebElement loginBtn = driver.findElement(By.xpath("//button[@id='loginButton']"));

        JavascriptExecutor js = (JavascriptExecutor) driver;
        js.executeScript("arguments[0].value = '';", usernameInput);
        usernameInput.sendKeys("user1");
        js.executeScript("arguments[0].value = '';", passwordInput);
        passwordInput.sendKeys("user123");
        loginBtn.click();

        // Verify successful redirection to Customer Dashboard
        WebElement welcomeHeading = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.xpath("//span[contains(text(),'Welcome, Gokul')]")));
        assertNotNull(welcomeHeading, "Customer Dashboard welcome banner should be visible");
    }

    @Test
    @Order(3)
    public void test03_SelectService() {
        WebElement serviceDropdown = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.xpath("//select[@id='serviceSelect']")));
        Select select = new Select(serviceDropdown);
        select.selectByVisibleText("Plumbing");
        assertEquals("Plumbing", select.getFirstSelectedOption().getText().trim());
    }

    @Test
    @Order(4)
    public void test04_TypeLandmarkAndAddress() {
        WebElement landmarkInput = driver.findElement(By.xpath("//input[@id='landmarkInput']"));
        WebElement addressInput = driver.findElement(By.xpath("//input[@id='addressInput']"));

        JavascriptExecutor js = (JavascriptExecutor) driver;
        js.executeScript("arguments[0].value = '';", landmarkInput);
        landmarkInput.sendKeys("Location A");

        js.executeScript("arguments[0].value = '';", addressInput);
        addressInput.sendKeys("42 North Cross Road");

        assertEquals("Location A", landmarkInput.getAttribute("value"));
        assertEquals("42 North Cross Road", addressInput.getAttribute("value"));
    }

    @Test
    @Order(5)
    public void test05_SelectRadius() {
        WebElement radiusDropdown = driver.findElement(By.xpath("//select[@id='radiusSelect']"));
        Select select = new Select(radiusDropdown);
        select.selectByValue("5");
        assertTrue(select.getFirstSelectedOption().getText().contains("5 km"));
    }

    @Test
    @Order(6)
    public void test06_FindProvidersAJAX() {
        WebElement findBtn = driver.findElement(By.xpath("//button[contains(text(),'FIND PROVIDERS')]"));
        findBtn.click();

        // Wait for AJAX response and JavaScript DOM creation of provider cards
        wait.until(ExpectedConditions.presenceOfElementLocated(
                By.xpath("//div[contains(@class,'provider-card')]")));

        List<WebElement> cards = driver.findElements(By.xpath("//div[contains(@class,'provider-card')]"));
        assertFalse(cards.isEmpty(), "At least one provider card should be dynamically generated via DOM");
    }

    @Test
    @Order(7)
    public void test07_VerifyProviderDistance() {
        WebElement distanceEl = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.xpath("//div[contains(@class,'provider-card')]//span[contains(@class,'distance-highlight')]")));
        String distanceText = distanceEl.getText();
        assertTrue(distanceText.contains("km"), "Distance text should contain 'km'");
    }

    @Test
    @Order(8)
    public void test08_RequestService() {
        WebElement requestBtn = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("(//div[contains(@class,'provider-card')]//button[contains(@class,'request-service')])[1]")));
        requestBtn.click();
    }

    @Test
    @Order(9)
    public void test09_VerifyBookingConfirmed() {
        WebElement confirmedHeading = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.xpath("//h1[contains(text(),'Booking Confirmed')]")));
        assertNotNull(confirmedHeading, "Booking Confirmed heading should appear");

        WebElement statusEl = driver.findElement(By.xpath("//span[contains(@id,'liveBookingStatus')]"));
        assertEquals("CONFIRMED", statusEl.getText().trim());
    }

    @Test
    @Order(10)
    public void test10_ProviderLoginAndCheckJob() {
        // Log out customer
        driver.get(BASE_URL + "/logout");

        // Log in as predefined provider Arun Kumar
        driver.get(BASE_URL + "/login.jsp");
        WebElement usernameInput = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.xpath("//input[@name='username']")));
        WebElement passwordInput = driver.findElement(By.xpath("//input[@name='password']"));
        WebElement loginBtn = driver.findElement(By.xpath("//button[@id='loginButton']"));

        JavascriptExecutor js = (JavascriptExecutor) driver;
        js.executeScript("arguments[0].value = '';", usernameInput);
        usernameInput.sendKeys("arun");
        js.executeScript("arguments[0].value = '';", passwordInput);
        passwordInput.sendKeys("arun123");
        loginBtn.click();

        // Wait for redirection to provider dashboard
        wait.until(ExpectedConditions.urlContains("/provider-dashboard"));

        // Verify provider dashboard and assigned job
        WebElement jobCard = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.xpath("//strong[contains(text(),'Booking #')]")));
        assertNotNull(jobCard, "Assigned booking card must be visible on provider dashboard");
    }

    @Test
    @Order(11)
    public void test11_ProviderAcceptBooking() {
        WebElement acceptBtn = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(text(),'ACCEPT')]")));
        acceptBtn.click();

        // Verify status changes to ACCEPTED and START SERVICE button appears
        WebElement startBtn = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.xpath("//button[contains(text(),'START SERVICE')]")));
        assertNotNull(startBtn, "START SERVICE button should be rendered after accepting");
    }

    @Test
    @Order(12)
    public void test12_ProviderStartAndCompleteService() {
        JavascriptExecutor js = (JavascriptExecutor) driver;

        // Step A: Start Service
        WebElement startBtn = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(text(),'START SERVICE')]")));
        js.executeScript("arguments[0].scrollIntoView({block: 'center'});", startBtn);
        js.executeScript("arguments[0].click();", startBtn);

        // Step B: Complete Service
        WebElement completeBtn = wait.until(ExpectedConditions.elementToBeClickable(
                By.xpath("//button[contains(text(),'COMPLETE SERVICE')]")));
        js.executeScript("arguments[0].scrollIntoView({block: 'center'});", completeBtn);
        js.executeScript("arguments[0].click();", completeBtn);

        // Step C: Verify Final Completed Status
        WebElement completedBadge = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.xpath("//span[contains(text(),'COMPLETED')]")));
        assertNotNull(completedBadge, "Status should transition to COMPLETED");
    }
}
