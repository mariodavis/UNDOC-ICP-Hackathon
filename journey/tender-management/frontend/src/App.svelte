<script>
  import { onMount } from 'svelte';
  import { user, login, logout } from './stores/auth';
  import TenderForm from './components/TenderForm.svelte';
  import TenderList from './components/TenderList.svelte';
  import Login from './components/Login.svelte';
  import Register from './components/Register.svelte';
  import Dashboard from './components/Dashboard.svelte';

  let isLoggedIn = false;
  let currentView = 'dashboard';

  onMount(() => {
    $user ? isLoggedIn = true : isLoggedIn = false;
  });

  const handleLogout = () => {
    logout();
    isLoggedIn = false;
    currentView = 'dashboard';
  };

  const handleViewChange = (view) => {
    currentView = view;
  };
</script>

<main>
  <h1>Tender Management System</h1>
  {#if isLoggedIn}
    <button on:click={handleLogout}>Logout</button>
    <button on:click={() => handleViewChange('dashboard')}>Dashboard</button>
    <button on:click={() => handleViewChange('tenders')}>Tenders</button>
    {#if currentView === 'dashboard'}
      <Dashboard />
    {:else if currentView === 'tenders'}
      <TenderList />
      <TenderForm />
    {/if}
  {:else}
    <button on:click={() => handleViewChange('login')}>Login</button>
    <button on:click={() => handleViewChange('register')}>Register</button>
    {#if currentView === 'login'}
      <Login />
    {:else if currentView === 'register'}
      <Register />
    {/if}
  {/if}
</main>
