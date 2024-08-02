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
