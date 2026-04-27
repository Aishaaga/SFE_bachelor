// IMPORTANT: This should be pure JavaScript, no HTML
document.getElementById('loginForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const errorDiv = document.getElementById('error');
    
    try {
        const response = await fetch('http://localhost:3000/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });
        
        const data = await response.json();
        
        if (data.success) {
            localStorage.setItem('adminToken', data.token);
            window.location.href = '/dashboard.html';
        } else {
            errorDiv.textContent = data.message || 'Login failed';
        }
    } catch (err) {
        errorDiv.textContent = 'Network error. Make sure backend is running on port 3000';
    }
});