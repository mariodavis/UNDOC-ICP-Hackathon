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
