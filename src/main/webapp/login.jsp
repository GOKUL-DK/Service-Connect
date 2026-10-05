<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.serviceconnect.dao.ServiceDAO" %>
<%@ page import="com.serviceconnect.model.Service" %>
<%@ page import="com.serviceconnect.util.CookieUtil" %>
<%
    String rememberedUsername = CookieUtil.getCookieValue(request, "rememberedUsername");
    if (rememberedUsername == null) rememberedUsername = "";

    String errorMessage = (String) request.getAttribute("errorMessage");
    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) {
        activeTab = request.getParameter("tab");
    }
    if (activeTab == null || activeTab.trim().isEmpty()) {
        activeTab = "signin";
    }

    String paramError = request.getParameter("error");
    String loggedOut = request.getParameter("loggedOut");
    String msg = request.getParameter("msg");

    if (errorMessage == null && "loginRequired".equals(paramError)) {
        errorMessage = "Please login to access your account.";
    } else if (errorMessage == null && "unauthorized".equals(paramError)) {
        errorMessage = "You do not have permission to access that resource.";
    }

    // Load services catalog for worker trade registration dropdown
    ServiceDAO serviceDAO = new ServiceDAO();
    List<Service> services = serviceDAO.getAllServices();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In or Register - ServiceConnect</title>
    <link rel="stylesheet" href="css/style.css?v=<%= System.currentTimeMillis() %>">
    <style>
        body {
            background: radial-gradient(circle at 10% 20%, rgba(238, 242, 255, 0.85) 0%, rgba(248, 250, 252, 1) 90%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .auth-container {
            max-width: 540px;
            margin: 2rem auto;
            width: 100%;
        }
        .auth-card {
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.12), 0 0 0 1px rgba(226, 232, 240, 0.9);
            padding: 2.25rem;
            position: relative;
            overflow: hidden;
        }
        .auth-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: var(--primary-gradient);
        }
        /* Top Navigation Tabs: Sign In vs Create Account */
        .auth-switcher {
            display: flex;
            background: #f1f5f9;
            border-radius: 12px;
            padding: 4px;
            gap: 4px;
            margin-bottom: 1.75rem;
            border: 1px solid var(--border);
        }
        .auth-tab-btn {
            flex: 1;
            padding: 0.75rem 1rem;
            border: none;
            background: transparent;
            font-size: 0.92rem;
            font-weight: 700;
            color: var(--text-muted);
            border-radius: 9px;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
        }
        .auth-tab-btn.active {
            background: #ffffff;
            color: var(--primary);
            box-shadow: 0 3px 10px rgba(15, 23, 42, 0.08);
        }
        /* Role Choice Cards: Customer vs Service Worker */
        .role-choice-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.85rem;
            margin-bottom: 1.35rem;
        }
        .role-choice-card {
            border: 2px solid var(--border);
            border-radius: 12px;
            padding: 0.9rem 0.85rem;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            background: #ffffff;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.3rem;
            user-select: none;
        }
        .role-choice-card:hover {
            border-color: var(--primary);
            background: #f8faff;
            transform: translateY(-2px);
        }
        .role-choice-card.selected {
            border-color: var(--primary);
            background: var(--primary-light);
            box-shadow: 0 0 0 1px var(--primary);
        }
        .role-choice-card .role-icon {
            font-size: 1.6rem;
        }
        .role-choice-card .role-title {
            font-size: 0.92rem;
            font-weight: 700;
            color: var(--secondary);
        }
        .role-choice-card .role-desc {
            font-size: 0.75rem;
            color: var(--text-muted);
            line-height: 1.25;
        }
    </style>
</head>
<body>

    <header class="navbar">
        <a href="index.jsp" class="nav-brand">
            <span class="brand-icon">⚡</span>
            <span>ServiceConnect</span>
        </a>
        <nav>
            <ul class="nav-menu">
                <li><a href="index.jsp" class="nav-link">Home</a></li>
                <li><a href="login.jsp" class="nav-link active">Sign In / Register</a></li>
            </ul>
        </nav>
    </header>

    <main class="container auth-container">
        <div class="auth-card">
            <!-- Header Icon & Brand -->
            <div style="text-align: center; margin-bottom: 1.5rem;">
                <div style="width: 56px; height: 56px; background: var(--primary-light); color: var(--primary); border-radius: 14px; display: inline-flex; align-items: center; justify-content: center; font-size: 1.8rem; margin-bottom: 0.65rem; box-shadow: 0 4px 14px rgba(79, 70, 229, 0.2);">
                    ⚡
                </div>
                <h1 id="authMainTitle" class="card-title" style="font-size: 1.65rem; justify-content: center; margin-bottom: 0.3rem;">
                    <%= "register".equalsIgnoreCase(activeTab) ? "Create Your Account" : "Sign In to ServiceConnect" %>
                </h1>
                <p id="authSubTitle" style="font-size: 0.88rem; color: var(--text-muted);">
                    <%= "register".equalsIgnoreCase(activeTab) ? "Join as a Customer or registered Service Worker" : "Access your account dashboard and active tasks" %>
                </p>
            </div>

            <!-- Top Switcher: Sign In vs Create Account -->
            <div class="auth-switcher">
                <button type="button" id="tabBtnSignIn" class="auth-tab-btn <%= !"register".equalsIgnoreCase(activeTab) ? "active" : "" %>" onclick="switchAuthMode('signin')">
                    🔐 Sign In
                </button>
                <button type="button" id="tabBtnRegister" class="auth-tab-btn <%= "register".equalsIgnoreCase(activeTab) ? "active" : "" %>" onclick="switchAuthMode('register')">
                    ✨ Create New Account
                </button>
            </div>

            <!-- Alert Messages -->
            <% if (loggedOut != null) { %>
                <div class="alert alert-info" style="margin-bottom: 1.25rem;">✓ You have been logged out successfully.</div>
            <% } %>

            <% if ("registered".equalsIgnoreCase(msg)) { %>
                <div class="alert alert-success" style="margin-bottom: 1.25rem;">✓ Account created successfully! Please sign in below.</div>
            <% } %>

            <% if (errorMessage != null) { %>
                <div class="alert alert-danger" style="margin-bottom: 1.25rem;">⚠️ <%= errorMessage %></div>
            <% } %>

            <!-- ==========================================
                 TAB 1: SIGN IN FORM
                 ========================================== -->
            <div id="signInSection" style="<%= "register".equalsIgnoreCase(activeTab) ? "display: none;" : "display: block;" %>">
                <form action="login" method="POST" id="loginForm">
                    <div class="form-group">
                        <label class="form-label" for="loginUsername">Username</label>
                        <input type="text" id="loginUsername" name="username" class="form-control" 
                               value="<%= rememberedUsername %>" placeholder="Enter your username" required autofocus>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="loginPassword">Password</label>
                        <input type="password" id="loginPassword" name="password" class="form-control" 
                               placeholder="Enter your password" required>
                    </div>

                    <div class="form-group" style="display: flex; align-items: center; gap: 0.6rem; margin-top: 0.6rem;">
                        <input type="checkbox" id="rememberMe" name="rememberMe" style="width: 17px; height: 17px; accent-color: var(--primary); cursor: pointer;" <%= !rememberedUsername.isEmpty() ? "checked" : "" %>>
                        <label for="rememberMe" style="font-size: 0.875rem; color: var(--text-muted); cursor: pointer; user-select: none;">
                            Remember username using HTTP Cookies
                        </label>
                    </div>

                    <button type="submit" id="loginButton" class="btn btn-primary btn-block" style="margin-top: 1.25rem; padding: 0.85rem; font-size: 0.95rem; font-weight: 700;">
                        Sign In →
                    </button>
                </form>

                <div style="text-align: center; margin-top: 1.35rem; padding-top: 1.25rem; border-top: 1px solid var(--border); font-size: 0.875rem; color: var(--text-muted);">
                    Don't have an account yet? 
                    <a href="javascript:void(0)" onclick="switchAuthMode('register')" style="color: var(--primary); font-weight: 700; text-decoration: underline; margin-left: 0.25rem;">
                        Create a free account
                    </a>
                </div>
            </div>

            <!-- ==========================================
                 TAB 2: CREATE NEW ACCOUNT FORM (USERS & WORKERS)
                 ========================================== -->
            <div id="registerSection" style="<%= "register".equalsIgnoreCase(activeTab) ? "display: block;" : "display: none;" %>">
                <form action="register" method="POST" id="registerForm">
                    <!-- Role Selection: Customer vs Service Worker -->
                    <div style="margin-bottom: 0.75rem;">
                        <label class="form-label" style="font-weight: 700; margin-bottom: 0.5rem; display: block;">I want to register as:</label>
                        <input type="hidden" name="role" id="registerRoleInput" value="CUSTOMER">

                        <div class="role-choice-grid">
                            <div id="roleCardCustomer" class="role-choice-card selected" onclick="selectRegisterRole('CUSTOMER')">
                                <span class="role-icon">👤</span>
                                <span class="role-title">Customer / User</span>
                                <span class="role-desc">Book nearby repairs & services</span>
                            </div>
                            <div id="roleCardWorker" class="role-choice-card" onclick="selectRegisterRole('PROVIDER')">
                                <span class="role-icon">🛠️</span>
                                <span class="role-title">Service Worker</span>
                                <span class="role-desc">Offer trades & accept job requests</span>
                            </div>
                        </div>
                    </div>

                    <!-- Common Fields -->
                    <div class="form-group">
                        <label class="form-label" for="regName">Full Legal Name</label>
                        <input type="text" id="regName" name="name" class="form-control" placeholder="e.g. Rahul Sharma" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="regUsername">Choose Username</label>
                        <input type="text" id="regUsername" name="username" class="form-control" placeholder="e.g. rahul123" required>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem;">
                        <div class="form-group">
                            <label class="form-label" for="regPassword">Password</label>
                            <input type="password" id="regPassword" name="password" class="form-control" placeholder="Min 6 characters" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="regConfirmPassword">Confirm Password</label>
                            <input type="password" id="regConfirmPassword" name="confirmPassword" class="form-control" placeholder="Re-enter password" required>
                        </div>
                    </div>

                    <!-- Worker-Specific Additional Fields -->
                    <div id="workerExtraFields" style="display: none; background: #f8fafc; border: 1px solid var(--border); border-radius: 12px; padding: 1.15rem; margin-top: 0.75rem; margin-bottom: 1.15rem;">
                        <div style="font-weight: 700; color: var(--secondary); font-size: 0.88rem; margin-bottom: 0.75rem; display: flex; align-items: center; gap: 0.4rem;">
                            <span>🛠️ Service Worker Profile Details</span>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="regServiceId">Primary Trade Category</label>
                            <select id="regServiceId" name="serviceId" class="form-select">
                                <% if (services != null) { 
                                       for (Service s : services) { %>
                                           <option value="<%= s.getServiceId() %>"><%= s.getServiceName() %> (<%= s.getDescription() %>)</option>
                                <%     } 
                                   } else { %>
                                    <option value="1">Plumbing</option>
                                    <option value="2">Electrical Repair</option>
                                    <option value="3">Carpentry</option>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="regPhone">Contact Phone Number</label>
                            <input type="tel" id="regPhone" name="phone" class="form-control" placeholder="10-digit mobile number, e.g. 9876543210">
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem;">
                            <div class="form-group">
                                <label class="form-label" for="regAvailableFrom">Shift Start Time</label>
                                <input type="time" id="regAvailableFrom" name="availableFrom" class="form-control" value="09:00">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="regAvailableUntil">Shift End Time</label>
                                <input type="time" id="regAvailableUntil" name="availableUntil" class="form-control" value="18:00">
                            </div>
                        </div>
                    </div>

                    <button type="submit" id="registerSubmitBtn" class="btn btn-primary btn-block" style="margin-top: 1.25rem; padding: 0.85rem; font-size: 0.95rem; font-weight: 700;">
                        Create Customer Account →
                    </button>
                </form>

                <div style="text-align: center; margin-top: 1.35rem; padding-top: 1.25rem; border-top: 1px solid var(--border); font-size: 0.875rem; color: var(--text-muted);">
                    Already have an account? 
                    <a href="javascript:void(0)" onclick="switchAuthMode('signin')" style="color: var(--primary); font-weight: 700; text-decoration: underline; margin-left: 0.25rem;">
                        Sign in here
                    </a>
                </div>
            </div>
        </div>
    </main>

    <footer class="footer" style="margin-top: auto;">
        <p>ServiceConnect &copy; 2026 – Advanced Java Web Technology Laboratory</p>
    </footer>

    <script>
        function switchAuthMode(mode) {
            const signInSec = document.getElementById('signInSection');
            const regSec = document.getElementById('registerSection');
            const tabBtnSignIn = document.getElementById('tabBtnSignIn');
            const tabBtnReg = document.getElementById('tabBtnRegister');
            const title = document.getElementById('authMainTitle');
            const subTitle = document.getElementById('authSubTitle');

            if (mode === 'register') {
                signInSec.style.display = 'none';
                regSec.style.display = 'block';
                tabBtnSignIn.classList.remove('active');
                tabBtnReg.classList.add('active');
                title.textContent = "Create Your Account";
                subTitle.textContent = "Join as a Customer or registered Service Worker";
                document.getElementById('regName').focus();
            } else {
                signInSec.style.display = 'block';
                regSec.style.display = 'none';
                tabBtnSignIn.classList.add('active');
                tabBtnReg.classList.remove('active');
                title.textContent = "Sign In to ServiceConnect";
                subTitle.textContent = "Access your account dashboard and active tasks";
                document.getElementById('loginUsername').focus();
            }
        }

        function selectRegisterRole(role) {
            const roleInput = document.getElementById('registerRoleInput');
            const cardCustomer = document.getElementById('roleCardCustomer');
            const cardWorker = document.getElementById('roleCardWorker');
            const workerFields = document.getElementById('workerExtraFields');
            const submitBtn = document.getElementById('registerSubmitBtn');

            roleInput.value = role;

            if (role === 'PROVIDER') {
                cardCustomer.classList.remove('selected');
                cardWorker.classList.add('selected');
                workerFields.style.display = 'block';
                submitBtn.textContent = "Register as Service Worker →";
            } else {
                cardCustomer.classList.add('selected');
                cardWorker.classList.remove('selected');
                workerFields.style.display = 'none';
                submitBtn.textContent = "Create Customer Account →";
            }
        }
    </script>
</body>
</html>
