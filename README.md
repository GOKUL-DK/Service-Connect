# ServiceConnect: Location-Based Multi-Service Booking and Provider Allocation System

ServiceConnect is a full-stack Java Web Technology laboratory application demonstrating end-to-end service allocation, location-radius calculations, asynchronous AJAX requests, XML configuration with DOM/XPath parsing, session management, cookies, and Selenium automated testing.

---

## 1. Technology Mapping

| Component | Technology | Role in ServiceConnect |
| :--- | :--- | :--- |
| **Frontend UI** | HTML5, Modern Vanilla CSS | Responsive customer & provider dashboards, cards, badges |
| **Client Scripting** | JavaScript (ES6) | Dynamic DOM manipulation (`document.createElement()`) |
| **Asynchronous I/O** | AJAX (Fetch API) | Non-reloading provider search and live status polling |
| **Dynamic Pages** | JSP 3.1 & Jakarta JSTL | Server-side templating for customer, provider, and admin views |
| **Server Controller** | Jakarta Servlets (Tomcat 10+) | Authentication, allocation dispatch, booking management |
| **Business Logic** | Core Java 17/21 | Haversine distance formula & Provider Allocation Algorithm |
| **Database** | MySQL 8.0 & Pure JDBC | Relational data persistence with `PreparedStatement` & `ResultSet` |
| **State Management** | HTTP Sessions (`HttpSession`) | Role-based authentication and secure session tracking |
| **Client Persistence** | HTTP Cookies (`Cookie`) | Remembering username, preferred service, and search radius |
| **Configuration** | XML (`service_rules.xml`) | Externalized search radius and service duration/fee limits |
| **XML Parsing** | Java DOM Parser & XPath | `DocumentBuilderFactory`, `Document`, `NodeList`, `XPath` |
| **Automation Testing** | Selenium WebDriver 4 + JUnit 5 | 12-step end-to-end browser test suite using XPath selectors |

---

## 2. Directory Structure

```text
ServiceConnect/
├── pom.xml
├── README.md
├── database/
│   └── schema.sql
├── src/
│   ├── main/
│   │   ├── java/com/serviceconnect/
│   │   │   ├── dao/
│   │   │   │   ├── BookingDAO.java
│   │   │   │   ├── LocationDAO.java
│   │   │   │   ├── ProviderDAO.java
│   │   │   │   ├── ServiceDAO.java
│   │   │   │   └── UserDAO.java
│   │   │   ├── model/
│   │   │   │   ├── Booking.java
│   │   │   │   ├── Location.java
│   │   │   │   ├── Provider.java
│   │   │   │   ├── Service.java
│   │   │   │   ├── ServiceRule.java
│   │   │   │   └── User.java
│   │   │   ├── service/
│   │   │   │   ├── BookingService.java
│   │   │   │   ├── ProviderAllocationService.java
│   │   │   │   └── XMLRuleService.java
│   │   │   ├── servlet/
│   │   │   │   ├── AdminDashboardServlet.java
│   │   │   │   ├── BookingServlet.java
│   │   │   │   ├── BookingStatusServlet.java
│   │   │   │   ├── FindProviderServlet.java
│   │   │   │   ├── LoginServlet.java
│   │   │   │   ├── LogoutServlet.java
│   │   │   │   ├── ProviderActionServlet.java
│   │   │   │   └── ProviderDashboardServlet.java
│   │   │   └── util/
│   │   │       ├── CookieUtil.java
│   │   │       ├── DBConnection.java
│   │   │       ├── DistanceUtil.java
│   │   │       └── XMLRuleParser.java
│   │   ├── resources/
│   │   │   └── service_rules.xml
│   │   └── webapp/
│   │       ├── css/
│   │       │   └── style.css
│   │       ├── js/
│   │       │   ├── booking.js
│   │       │   └── provider-search.js
│   │       ├── WEB-INF/
│   │       │   └── web.xml
│   │       ├── admin-dashboard.jsp
│   │       ├── booking.jsp
│   │       ├── confirmation.jsp
│   │       ├── customer-dashboard.jsp
│   │       ├── index.jsp
│   │       ├── login.jsp
│   │       └── provider-dashboard.jsp
│   └── test/
│       └── java/com/serviceconnect/
│           ├── selenium/
│           │   └── ServiceConnectTest.java
│           └── service/
│               └── AllocationAndDistanceTest.java
```

---

## 3. Predefined Credentials

| Role | Username | Password | Full Name | Trade / Service | Capability |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **CUSTOMER** | `user1` | `user123` | Gokul | Customer | Search nearby providers, distance sort, request service |
| **CUSTOMER** | `user2` | `user123` | Priya | Customer | Bookings history for Carpentry, Cleaning |
| **CUSTOMER** | `user3` | `user123` | Ananya Sharma | Customer | Bookings history for Appliance Repair, Painting |
| **CUSTOMER** | `user4` | `user123` | Kavitha Nair | Customer | Bookings history for Computer Repair, Pest Control |
| **CUSTOMER** | `user5` | `user123` | Rohan Verma | Customer | Bookings history for Vehicle Repair, Solar Panel Service |
| **CUSTOMER** | `user6` | `user123` | Deepak Raj | Customer | Bookings history for Home Maintenance, CCTV Security |
| **PROVIDER** | `arun` | `arun123` | Arun Kumar | Plumbing | Plumber (~0.37 km from Loc A), Accept/Start/Complete tasks |
| **PROVIDER** | `bala` | `bala123` | Bala Kumar | Plumbing | Plumber (~1.12 km from Loc A), secondary candidate |
| **PROVIDER** | `ravi` | `ravi123` | Ravi | Electrical Repair | Electrician, active jobs in progress |
| **PROVIDER** | `karthik` | `karthik123` | Karthik | Carpentry | Wood fittings & furniture repairs |
| **PROVIDER** | `suresh` | `suresh123` | Suresh | AC Service | Air conditioner servicing & maintenance |
| **PROVIDER** | `manoj` | `manoj123` | Manoj | Appliance Repair | Washing machines, refrigerators & microwaves |
| **PROVIDER** | `vijay` | `vijay123` | Vijay | Computer Repair | Desktop & laptop diagnostics & repairs |
| **PROVIDER** | `prakash` | `prakash123` | Prakash | Painting | Wall painting & waterproofing |
| **PROVIDER** | `ramesh` | `ramesh123` | Ramesh | Cleaning | Deep home cleaning & sanitation |
| **PROVIDER** | `ajay` | `ajay123` | Ajay | Vehicle Repair | Two-wheeler & four-wheeler servicing |
| **PROVIDER** | `dinesh` | `dinesh123` | Dinesh | Home Maintenance | Handyman, masonry & fixtures |
| **PROVIDER** | `vikram` | `vikram123` | Vikram | Pest Control | Termite eradication & pest control |
| **PROVIDER** | `anand` | `anand123` | Anand | Solar Panel Service | Solar cleaning & inverter maintenance |
| **PROVIDER** | `murugan` | `murugan123` | Murugan | Gardening & Lawn Care | Lawn care & garden maintenance |
| **PROVIDER** | `saravanan` | `saravanan123` | Saravanan | CCTV & Smart Security | Security cameras & smart doorbell setups |
| **ADMIN** | `admin` | `admin123` | Administrator | System Admin | System metrics, registry inspection, active queue |

---

## 4. Quick Setup & Execution

### Step 1: Initialize Database
Execute `database/schema.sql` in MySQL:
```bash
mysql -u root -p < database/schema.sql
```
*(Default DB password in `DBConnection.java` is `root`. Modify `DBConnection.java` if your local MySQL root password differs.)*

### Step 2: Build with Maven
In the `ServiceConnect` folder:
```bash
mvn clean package
```
This builds `target/ServiceConnect.war`.

### Step 3: Run on Apache Tomcat 10+
- Copy `target/ServiceConnect.war` to Tomcat's `webapps/` folder.
- Start Tomcat:
  - Windows: `<TOMCAT_HOME>\bin\startup.bat`
  - Linux/Mac: `<TOMCAT_HOME>/bin/startup.sh`
- Open your browser at:
  ```text
  http://localhost:8080/ServiceConnect/
  ```

### Step 4: Run Automated Selenium Tests
Ensure Chrome is installed and Tomcat is running, then execute either:

**Option A: Fast Batch Runner (< 5 seconds)**
```cmd
run-selenium-test.bat
```

**Option B: Maven Test**
```bash
mvn test -Dtest=ServiceConnectTest -o
```

To run with visible browser window:
```bash
mvn test -Dtest=ServiceConnectTest -Dheadless=false
```

---

## 5. Demo Test Credentials

The application includes pre-configured accounts for testing each role:

| Role | Username | Password | Features & Workflows |
| :--- | :--- | :--- | :--- |
| **Customer** | `john` | `password123` | Customer Dashboard, Dark Leaflet Map, Haversine Radius Matching, Live Chat, OTP Handshake |
| **Service Worker (Electrician)** | `ramesh` | `pass123` | Provider Dashboard, Job Queue, Direct Customer Messaging, Inline Incident Escalation |
| **Service Worker (Plumber)** | `suresh` | `pass123` | Job Queue, Shift Hours / Availability Status Management, Task State Transitions |
| **Administrator** | `admin` | `admin123` | Analytics Console, Neon Chart.js Data Visualizations, Grievance Dispute Moderation |

---

## 6. Cloud & Docker Deployment

### Option A: 1-Click Cloud Deployment via Railway (Recommended)
1. Fork or push this repository to your GitHub account (`GOKUL-DK/Service-Connect`).
2. Log in to [Railway.app](https://railway.app/) and click **New Project** -> **Deploy from GitHub repo**.
3. Select this repository. Railway automatically detects the multi-stage `Dockerfile`.
4. Click **+ New** in your Railway project canvas and select **Database** -> **Add MySQL**.
5. ServiceConnect automatically detects Railway's `MYSQL_URL` / `DATABASE_URL` and initializes the entire schema with predefined demo accounts on startup.
6. Under your Web Service settings, generate a public domain (`your-app.up.railway.app`). Open it in your browser!

### Option B: Cloud Deployment via Render
1. Go to [Render.com](https://render.com/) and click **New +** -> **Web Service**.
2. Connect your GitHub repository.
3. Select **Docker** as the Runtime.
4. Add your MySQL connection string under **Environment Variables**:
   - `DATABASE_URL`: `mysql://username:password@hostname:3306/dbname`
   *(Or set `DB_URL`, `DB_USER`, and `DB_PASSWORD` individually).*
5. Click **Deploy Web Service**.

### Option C: Local Multi-Container Run with Docker Compose
Run both the MySQL database and the Tomcat container locally with zero manual setup:
```bash
docker-compose up --build
```
Open `http://localhost:8080/` in your browser.

