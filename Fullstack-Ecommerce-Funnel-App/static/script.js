async function loadData(type = 'funnel') {
  const response = await fetch(`/api/${type}`);
  const data = await response.json();

  let trace;
  let layout = {
    title: '',
    font: { size: 14 },
    margin: { l: 120, r: 60, t: 80, b: 60 }
  };

  if (type === 'funnel') {
    // overall funnel
    const stages = ['view', 'cart', 'purchase'];
    const users = stages.map(s => {
      const item = data.find(d => d.event_type === s);
      return item ? item.unique_users : 0;
    });

    trace = {
      type: 'funnel',
      y: stages,
      x: users,
      textinfo: 'value+percent initial',
      marker: { color: ['#1a73e8', '#34a853', '#fbbc05'] }
    };
    layout.title = 'User Conversion Funnel';
  }

  if (type === 'category') {
    trace = {
      type: 'bar',
      x: data.map(d => d.view_to_purchase_rate),
      y: data.map(d => d.category_code),
      orientation: 'h',
      marker: { color: '#1a73e8' }
    };
    layout.title = 'Conversion Rate by Category';
    layout.xaxis = { title: 'View → Purchase Rate (%)' };
  }

  if (type === 'brand') {
    trace = {
      type: 'bar',
      x: data.map(d => d.view_to_purchase_rate),
      y: data.map(d => d.brand),
      orientation: 'h',
      marker: { color: '#34a853' }
    };
    layout.title = 'Conversion Rate by Brand';
    layout.xaxis = { title: 'View → Purchase Rate (%)' };
  }

  Plotly.newPlot('chart', [trace], layout);
}

// initial load
loadData('funnel');

// dropdown change
document.getElementById('filter').addEventListener('change', (e) => {
  loadData(e.target.value);
});
