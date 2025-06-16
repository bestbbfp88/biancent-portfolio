let reportResultDiv; 

document.addEventListener("DOMContentLoaded", async () => {

    reportResultDiv = document.getElementById('reportResult');

    const populateDateFilters = () => {
        console.log('📅 Populating date filters...');
        const dbRef = firebase.database().ref('emergencies');

        dbRef.once('value', function(snapshot) {
            const data = snapshot.val();
            let years = new Set();
            let months = new Set();

            if (data) {
                for (let key in data) {
                    const incident = data[key];
                    const dateTime = new Date(incident.date_time);
                    if (!isNaN(dateTime)) {
                        years.add(dateTime.getFullYear());
                        months.add(dateTime.getMonth() + 1);
                    } else {
                        console.warn(`⚠️ Invalid date for key ${key}:`, incident.date_time);
                    }
                }
            }

            const yearSelect = document.getElementById('reportYear');
            years.forEach(year => {
                const option = document.createElement('option');
                option.value = year;
                option.textContent = year;
                yearSelect.appendChild(option);
            });

            const monthSelect = document.getElementById('reportMonth');
            months.forEach(month => {
                const option = document.createElement('option');
                option.value = month < 10 ? '0' + month : month;
                option.textContent = new Date(0, month - 1).toLocaleString('default', { month: 'long' });
                monthSelect.appendChild(option);
            });
        });
    };

    document.getElementById('generateReportButton').addEventListener('click', () => {
        const year = document.getElementById('reportYear').value;
        let month = document.getElementById('reportMonth').value;
        if (month === "Choose Month") {
            month = ""; // treat as not selected
        }

        const place = document.getElementById('reportPlace').value;
        const status = document.getElementById('reportStatus').value;
        const emergencyType = document.getElementById('reportEmergencyType').value;

    
        if (!year) {
            alert('⚠️ Please select a Year to generate the report.');
            return;
        }
    
        console.log(`📤 Generating report for: ${year}-${month || 'All'}, Place: ${place || 'Any'}, Status: ${status || 'Any'}`);
        generateReport(year, month, place, status, emergencyType);
    });
    

    async function generateReport(year, month, place, status, emergencyType) {

        reportResultDiv.innerHTML = ''; // ✅ Always clear old results first
        reportResultDiv.style.display = 'none'; // ✅ Also hide initially
        
        const dbRef = firebase.database().ref('emergencies');
        const snapshot = await dbRef.once('value');
        const rawData = snapshot.val() || {};
       
        console.log(`🧾 Raw emergencies loaded: ${Object.keys(rawData).length}`);
        console.log(`📅 Filter period: ${year}-${month || 'ALL'}`);

        const result = {};

        const start = new Date(`${year}-${month || '01'}-01T00:00:00`);
        const end = month
          ? new Date(`${year}-${month}-31T23:59:59`)
          : new Date(`${year}-12-31T23:59:59`);
        


        console.log("🕒 Date range:", start.toISOString(), "→", end.toISOString());

        for (let key in rawData) {
            const item = rawData[key];
            const incidentDate = new Date(item.date_time);

            if (!item.date_time || isNaN(incidentDate)) {
                console.warn(`⚠️ Skipping entry ${key} due to invalid date_time:`, item.date_time);
                continue;
            }

            const inDateRange = incidentDate >= start && incidentDate <= end;


            if (inDateRange) {
                result[key] = item;
            }
        }

         // Filter by emergency type
         if (emergencyType && emergencyType !== "") {
            for (let key in { ...result }) {
                const incident = result[key];

                if (incident.dispatch_ID) {
                    const ticketSnap = await firebase.database().ref(`tickets/${incident.dispatch_ID}`).once("value");
                    const ticketData = ticketSnap.val();

                    if (ticketData && ticketData.emergencyType) {
                        const normalizedType = ticketData.emergencyType.trim().toUpperCase();
                        if (normalizedType !== emergencyType.toUpperCase()) {
                            console.log(`❌ Excluding ${key} due to emergency type mismatch: ${ticketData.emergencyType}`);
                            delete result[key];
                        }
                    } else {
                        delete result[key]; // No emergencyType found at all
                    }
                } else {
                    delete result[key]; // No dispatch_ID, skip
                }
            }
        }

        // Filter by status
        if (status && status !== "Any") {
            for (let key in { ...result }) {
                if (result[key].report_Status !== status) {
                    console.log(`❌ Excluding ${key} due to status mismatch: ${result[key].report_Status}`);
                    delete result[key];
                }
            }
        }

        // Filter by place
        if (place && place.trim() !== '') {
            const placeLower = place.toLowerCase();
            for (let key in { ...result }) {
                const location = result[key].location?.toLowerCase() || '';
                if (!location.includes(placeLower)) {
                    console.log(`❌ Excluding ${key} due to location mismatch: ${location}`);
                    delete result[key];
                }
            }
        }

        console.log("✅ Final filtered entries:", Object.keys(result));

        if (Object.keys(result).length === 0) {
            reportResultDiv.innerHTML = `
                <div class="alert alert-warning text-center fw-bold" role="alert">
                    🚫 No data available for the selected filters.
                </div>
            `;
            reportResultDiv.style.display = 'block';
            return;
        }
        

        // Count emergency types
    const typeCount = {};
    const labelMap = {
        MEDICAL: "Medical",
        MVC: "MVC",
        TRAUMA: "Trauma",
        POLICE: "Police",
        FIRE: "Fire",
        TRANSPORT: "Transport",
        OTHERS: "Others"
    };

    for (let key in result) {
        const incident = result[key];

        if (incident.dispatch_ID) {
            const ticketSnap = await firebase.database().ref(`tickets/${incident.dispatch_ID}`).once("value");
            const ticketData = ticketSnap.val();

            if (ticketData && ticketData.emergencyType) {
                const normalizedType = ticketData.emergencyType.trim().toUpperCase();
                const typeKey = labelMap[normalizedType] ? normalizedType : "OTHERS";
                typeCount[typeKey] = (typeCount[typeKey] || 0) + 1;
            } else {
                typeCount.OTHERS = (typeCount.OTHERS || 0) + 1;
            }
        } else {
            typeCount.OTHERS = (typeCount.OTHERS || 0) + 1;
        }
    }


        let totalResponses = Object.keys(result).length;

        let summaryHTML = `<p class="fw-bold text-primary mb-3 fs-5">Total Number of Emergency Responses: ${totalResponses}</p>`;

        let tableHTML = `
        <div class="table-responsive mb-4">
        <table class="table table-bordered table-striped align-middle text-center">
            <thead class="table-dark">
            <tr>
                <th>Emergency Type</th>
                <th>Number of Responses</th>
            </tr>
            </thead>
            <tbody>
        `;

        for (let type in typeCount) {
            const label = labelMap[type] || type;
            tableHTML += `
            <tr>
                <td>${label}</td>
                <td>${typeCount[type]}</td>
            </tr>
            `;
        }

        tableHTML += `
            </tbody>
        </table>
        </div>
        `;

        reportResultDiv.innerHTML = `
        ${summaryHTML}
        ${tableHTML}
        <div class="row">
            <div class="col-md-6 mb-4">
            <div class="border rounded p-2 bg-white">
                <canvas id="typeChart" style="width: 100%; height: 300px;"></canvas>
            </div>
            </div>
            <div class="col-md-6 mb-4">
            <div id="heatmapContainer" class="border rounded p-2 bg-white" style="width: 100%; height: 300px;"></div>
            </div>
        </div>

        <div class="text-end">
            <button type="button" class="btn btn-outline-secondary ms-2" id="printReportButton">
                <i class="fas fa-print me-1"></i> Print Report
            </button>
        </div>
        `;
        renderChart(typeCount);
        window.heatmap.initMapHeat(result);

        reportResultDiv.style.display = 'block';

        document.getElementById('printReportButton').addEventListener('click', () => {
            generatePDF('reportResult', 'Emergency Report Summary');
        });
        
    }

    
    populateDateFilters();

    document.getElementById('printReportButton').addEventListener('click', () => {
        generatePDF('reportResult', 'Emergency Report Summary');
      });
      
      
});

function renderChart(typeCount) {
    const ctx = document.getElementById('typeChart').getContext('2d');
    if (window.typeChartInstance) {
        window.typeChartInstance.destroy();
    }

    const labelMap = {
        MEDICAL: "Medical",
        MVC: "MVC",
        TRAUMA: "Trauma",
        POLICE: "Police",
        FIRE: "Fire",
        TRANSPORT: "Transport",
        OTHERS: "Others"
    };

    const chartLabels = Object.keys(typeCount).map(key => labelMap[key] || key);
    const chartValues = Object.values(typeCount);

    window.typeChartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: chartLabels,
            datasets: [{
                label: 'Emergency Responses',
                data: chartValues,
                backgroundColor: [
                    '#007bff', '#fd7e14', '#6c757d',
                    '#ffc107', '#dc3545', '#28a745', '#6f42c1'
                ]
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                title: {
                    display: true,
                    text: 'Emergency Responses by Type'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { precision: 0 }
                }
            }
        }
    });
}

async function generatePDF(elementId, title = 'Emergency Report Summary') {
    const element = document.getElementById(elementId);
    if (!element) {
        console.error('❌ Element not found with ID:', elementId);
        alert('❌ Element not found!');
        return;
    }

    const { jsPDF } = window.jspdf;
    const pdf = new jsPDF({ orientation: 'landscape', unit: 'pt', format: 'a4' });

    const chartCanvas = element.querySelector('canvas');
    const heatmapContainer = document.getElementById('heatmapContainer');
    const tableElement = element.querySelector('table'); 
    
    let chartImg;
    if (chartCanvas) {
        const chartDataURL = chartCanvas.toDataURL();
        chartImg = { src: chartDataURL, width: 780, height: 400, x: 30, y: 60 };
    }

    let mapImg;
    if (heatmapContainer) {
        const mapCanvas = await html2canvas(heatmapContainer, { useCORS: true, backgroundColor: '#fff' });
        const mapDataURL = mapCanvas.toDataURL();
        mapImg = { src: mapDataURL, width: 780, height: 400, x: 30, y: 60 };
    }

    let tableImg;
    if (tableElement) {
        const tableCanvas = await html2canvas(tableElement, { useCORS: true, backgroundColor: '#fff' });
        const tableDataURL = tableCanvas.toDataURL();
        tableImg = { src: tableDataURL, width: 780, height: tableCanvas.height * (780 / tableCanvas.width), x: 30, y: 60 };
    }

    pdf.setFont('helvetica', 'bold');
    pdf.setFontSize(20);
    pdf.text(title, 40, 40);

    if (chartImg) {
        pdf.addImage(chartImg.src, 'PNG', chartImg.x, chartImg.y, chartImg.width, chartImg.height);
    }

    if (tableImg) {
        pdf.addPage();
        pdf.setFontSize(16);
        pdf.text('Emergency Type Summary Table', 40, 40);
        pdf.addImage(tableImg.src, 'PNG', tableImg.x, tableImg.y, tableImg.width, tableImg.height);
    }

    if (mapImg) {
        pdf.addPage();
        pdf.setFontSize(16);
        pdf.text('Heatmap Snapshot', 40, 40);
        pdf.addImage(mapImg.src, 'PNG', mapImg.x, mapImg.y, mapImg.width, mapImg.height);
    }

    pdf.save(`${title.replace(/\s+/g, '_')}.pdf`);
}
