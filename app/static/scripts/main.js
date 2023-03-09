fetch('/api/v1/skills')
  .then(function(response) {
    return response.json();
  })
  .then(function(data) {
    document.getElementById('footer').textContent = data.skill.toUpperCase();
  });