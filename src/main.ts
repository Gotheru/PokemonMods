import './style.css';

const app = document.querySelector<HTMLDivElement>('#app');

if (!app) {
  throw new Error('Root app container not found');
}

app.innerHTML = `
  <main class="hero">
    <h1>Pokemon Mods Hub</h1>
    <p class="lead">Welcome! This will soon be the home for docs, tools, and community-made enhancements for the Pokemon Essentials modding scene.</p>
    <p>We are just getting started?stay tuned as we add guides, download links, and project showcases.</p>
  </main>
`;