#!/bin/bash

# Define project directory
PROJECT_DIR="tender-management/frontend"

# Function to check and install a package if not installed
install_if_not_installed() {
  PACKAGE_NAME=$1
  if ! dpkg -l | grep -q $PACKAGE_NAME; then
    echo "$PACKAGE_NAME not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y $PACKAGE_NAME
  else
    echo "$PACKAGE_NAME is already installed."
  fi
}

# Install prerequisites
install_if_not_installed "curl"
install_if_not_installed "git"

# Install Node.js and npm
if ! command -v node &> /dev/null; then
  echo "Node.js not found. Installing..."
  curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt-get install -y nodejs
else
  echo "Node.js is already installed."
fi

# Install npx (comes with npm)
if ! command -v npx &> /dev/null; then
  echo "npx not found. Installing npm..."
  sudo apt-get install -y npm
else
  echo "npx is already installed."
fi

# Create project directory
mkdir -p $PROJECT_DIR/src/components

# Change to project directory
cd $PROJECT_DIR

# Create package.json
cat << 'EOF' > package.json
{
  "name": "svelte-tender-management",
  "version": "1.0.0",
  "scripts": {
    "build": "rollup -c",
    "dev": "rollup -c -w",
    "start": "sirv public --no-clear"
  },
  "devDependencies": {
    "rollup": "^2.3.4",
    "rollup-plugin-commonjs": "^10.1.0",
    "rollup-plugin-node-resolve": "^5.2.0",
    "rollup-plugin-svelte": "^5.0.3",
    "rollup-plugin-terser": "^5.1.2",
    "svelte": "^3.17.3"
  },
  "dependencies": {
    "@dfinity/agent": "^0.8.1",
    "@dfinity/candid": "^0.8.1",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^8.5.1"
  }
}
EOF

# Create rollup.config.js
cat << 'EOF' > rollup.config.js
import svelte from 'rollup-plugin-svelte';
import commonjs from 'rollup-plugin-commonjs';
import resolve from 'rollup-plugin-node-resolve';
import { terser } from 'rollup-plugin-terser';
import livereload from 'rollup-plugin-livereload';
import css from 'rollup-plugin-css-only';

const production = !process.env.ROLLUP_WATCH;

export default {
  input: 'src/main.js',
  output: {
    sourcemap: true,
    format: 'iife',
    name: 'app',
    file: 'public/build/bundle.js',
  },
  plugins: [
    svelte({
      dev: !production,
      css: (css) => {
        css.write('bundle.css');
      },
    }),
    css({ output: 'public/build/extra.css' }),
    resolve({
      browser: true,
      dedupe: ['svelte'],
    }),
    commonjs(),
    !production && livereload('public'),
    production && terser(),
  ],
  watch: {
    clearScreen: false,
  },
};
EOF

# Create public/index.html
mkdir -p public
cat << 'EOF' > public/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Svelte App</title>
  <link rel="stylesheet" href="global.css" />
  <link rel="stylesheet" href="build/bundle.css" />
</head>
<body>
  <div id="app"></div>
  <script src="build/bundle.js"></script>
</body>
</html>
EOF

# Create public/global.css
cat << 'EOF' > public/global.css
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, 'Noto Sans', sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
}

main {
  max-width: 800px;
  margin: 2rem auto;
  padding: 0 1rem;
}

h1 {
  font-size: 2.5rem;
  text-align: center;
}

button {
  margin-top: 1rem;
}

form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
EOF

# Create src/main.js
mkdir -p src
cat << 'EOF' > src/main.js
import App from './App.svelte';

const app = new App({
  target: document.body,
});

export default app;
EOF

# Create src/App.svelte
cat << 'EOF' > src/App.svelte
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
EOF

# Create src/components/TenderForm.svelte
mkdir -p src/components
cat << 'EOF' > src/components/TenderForm.svelte
<script>
  import { createTender } from '../services/tenderService';
  let title = '';
  let description = '';
  let end_date = '';

  const handleSubmit = async () => {
    await createTender(title, description, end_date);
    title = '';
    description = '';
    end_date = '';
  };
</script>

<form on:submit|preventDefault={handleSubmit}>
  <label for="title">Title</label>
  <input type="text" id="title" bind:value={title} />

  <label for="description">Description</label>
  <input type="text" id="description" bind:value={description} />

  <label for="end_date">End Date</label>
  <input type="date" id="end_date" bind:value={end_date} />

  <button type="submit">Create Tender</button>
</form>
EOF

# Create src/components/TenderList.svelte
cat << 'EOF' > src/components/TenderList.svelte
<script>
  import { getTenders } from '../services/tenderService';
  let tenders = [];

  onMount(async () => {
    tenders = await getTenders();
  });
</script>

<ul>
  {#each tenders as tender}
    <li>
      <h3>{tender.title}</h3>
      <p>{tender.description}</p>
      <p>End Date: {tender.end_date}</p>
      <p>Status: {tender.status}</p>
    </li>
  {/each}
</ul>
EOF

# Create src/components/Login.svelte
cat << 'EOF' > src/components/Login.svelte
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
EOF

# Create src/components/Register.svelte
cat << 'EOF' > src/components/Register.svelte
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
EOF

# Create src/components/Dashboard.svelte
cat << 'EOF' > src/components/Dashboard.svelte
<script>
  // Add any dashboard-specific logic here
</script>

<main>
  <h2>Dashboard</h2>
  <p>Welcome to the Tender Management System Dashboard!</p>
</main>
EOF

# Create src/services/tenderService.js
mkdir -p src/services
cat << 'EOF' > src/services/tenderService.js
import { HttpAgent } from '@dfinity/agent';
import { idlFactory as tenderIdl } from '../../../backend/declarations/tender_management';

const agent = new HttpAgent();
const tenderCanister = new agent.canister(tenderIdl);

export const createTender = async (title, description, end_date) => {
  await tenderCanister.create_tender(title, description, end_date);
};

export const getTenders = async () => {
  return await tenderCanister.get_tenders();
};
EOF

# Create src/services/authService.js
cat << 'EOF' > src/services/authService.js
import { HttpAgent } from '@dfinity/agent';
import { idlFactory as authIdl } from '../../../backend/declarations/tender_management';

const agent = new HttpAgent();
const authCanister = new agent.canister(authIdl);

export const login = async (username, password) => {
  return await authCanister.login(username, password);
};

export const register = async (username, password, role) => {
  await authCanister.register(username, password, role);
};
EOF

# Install npm packages
npm install

# Set permissions to executable
chmod +x *.sh

echo "Frontend setup is complete. To start the frontend server, run the following commands:"
echo "1. cd $PROJECT_DIR"
echo "2. npm run dev"
