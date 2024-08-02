<script>
  import { login } from '../services/authService';
  let username = '';
  let password = '';

  const handleLogin = async () => {
    const success = await login(username, password);
    if (success) {
      // Redirect or update state
    } else {
      // Handle login failure
    }
  };
</script>

<form on:submit|preventDefault={handleLogin}>
  <label for="username">Username</label>
  <input type="text" id="username" bind:value={username} />

  <label for="password">Password</label>
  <input type="password" id="password" bind:value={password} />

  <button type="submit">Login</button>
</form>
