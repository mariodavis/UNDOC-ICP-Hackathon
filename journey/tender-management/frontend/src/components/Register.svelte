<script>
  import { register } from '../services/authService';
  let username = '';
  let password = '';
  let role = '';

  const handleRegister = async () => {
    await register(username, password, role);
    // Redirect or update state
  };
</script>

<form on:submit|preventDefault={handleRegister}>
  <label for="username">Username</label>
  <input type="text" id="username" bind:value={username} />

  <label for="password">Password</label>
  <input type="password" id="password" bind:value={password} />

  <label for="role">Role</label>
  <input type="text" id="role" bind:value={role} />

  <button type="submit">Register</button>
</form>
