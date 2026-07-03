package filter;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;

@WebFilter(
    urlPatterns = {"*.jsp", ""},
    dispatcherTypes = {DispatcherType.REQUEST, DispatcherType.FORWARD}
)
public class SecurityFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Init logic if required
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String uri = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = uri.substring(contextPath.length());
        
        // Normalize welcome folder path and filenames
        String pageName = path.substring(path.lastIndexOf("/") + 1);
        if (pageName.isEmpty() || path.equals("/")) {
            pageName = "index.jsp";
        }

        // Detect role target pages
        boolean isAdminPage = pageName.startsWith("admin-");
        boolean isOfficerPage = pageName.startsWith("officer-");
        boolean isUserPage = pageName.startsWith("user-") && !pageName.equals("user-login.jsp") && !pageName.equals("user-register.jsp");

        boolean isProtectedPage = isAdminPage || isOfficerPage || isUserPage;
        boolean isLoginPage = pageName.equals("login.jsp") || pageName.equals("user-login.jsp");
        // Only redirect away from the landing homepage for logged-in users, NOT from content pages like readings/semak-status
        boolean isPublicPage = pageName.equals("index.jsp") || pageName.equals("index2.jsp");

        HttpSession session = httpRequest.getSession(false);
        boolean loggedIn = false;
        String role = null;

        if (session != null) {
            String userType = (String) session.getAttribute("userType");
            if (userType != null) {
                if ("admin".equals(userType) && session.getAttribute("adminUsername") != null) {
                    loggedIn = true;
                    role = "admin";
                } else if ("officer".equals(userType) && session.getAttribute("officerUsername") != null) {
                    loggedIn = true;
                    role = "officer";
                } else if ("user".equals(userType) && session.getAttribute("userEmail") != null) {
                    loggedIn = true;
                    role = "user";
                }
            }
        }

        // Apply strict cache-control on protected pages
        if (isProtectedPage) {
            httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
            httpResponse.setHeader("Pragma", "no-cache"); // HTTP 1.0
            httpResponse.setDateHeader("Expires", 0); // Proxies

            if (!loggedIn) {
                // Not logged in -> redirect to login screen
                httpResponse.sendRedirect(contextPath + "/login.jsp");
                return;
            }
        }

        // Prevent returning to Login or landing pages if already authenticated
        if (loggedIn && (isLoginPage || isPublicPage)) {
            if ("admin".equals(role)) {
                httpResponse.sendRedirect(contextPath + "/admin-dashboard.jsp");
            } else if ("officer".equals(role)) {
                httpResponse.sendRedirect(contextPath + "/officer-dashboard.jsp");
            } else if ("user".equals(role)) {
                httpResponse.sendRedirect(contextPath + "/user-places.jsp");
            }
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup if required
    }
}
