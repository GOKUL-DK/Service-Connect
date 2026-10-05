/**
 * ServiceConnect - Ultra-Modern Provider Search, Leaflet GPS Radar & Dynamic DOM Rendering
 * Demonstrates:
 * - Asynchronous AJAX (Fetch API) without reloading page
 * - Dynamic JavaScript DOM creation strictly per Java Web Tech requirements
 * - Interactive Leaflet Map with OpenStreetMap pins & search radius circles
 * - Browser Geolocation API ("Use My GPS") integration
 * - Dynamic bill calculation, Emergency SOS surcharge handling, and responsive dispatch
 */

document.addEventListener("DOMContentLoaded", function () {
    const searchForm = document.getElementById("providerSearchForm");
    const findProvidersBtn = document.getElementById("findProvidersBtn");
    const resultsContainer = document.getElementById("providerResultsContainer");
    const statusAlert = document.getElementById("searchStatusAlert");
    const useGpsBtn = document.getElementById("useGpsBtn");
    const emergencyToggle = document.getElementById("emergencyToggle");

    // Initialize Leaflet Map
    let leafletMap = null;
    let userMarker = null;
    let radiusCircle = null;
    let providerMarkersLayer = null;

    const mapElement = document.getElementById("serviceMap");
    if (mapElement && typeof L !== "undefined") {
        try {
            leafletMap = L.map("serviceMap").setView([11.0168, 76.9558], 12);
            L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
                maxZoom: 19,
                attribution: "© OpenStreetMap contributors"
            }).addTo(leafletMap);

            providerMarkersLayer = L.layerGroup().addTo(leafletMap);

            // Default user marker at Coimbatore Center
            userMarker = L.marker([11.0168, 76.9558]).addTo(leafletMap)
                .bindPopup("<b>📍 Default Search Location</b><br>Coimbatore Central");
        } catch (e) {
            console.warn("Leaflet map initialization skipped or failed:", e);
        }
    }

    // Geolocation handler
    if (useGpsBtn) {
        useGpsBtn.addEventListener("click", function () {
            if (!navigator.geolocation) {
                showStatus("Geolocation is not supported by your browser.", "warning");
                return;
            }
            showStatus("Detecting your live GPS coordinates...", "info");
            navigator.geolocation.getCurrentPosition(
                function (pos) {
                    const lat = pos.coords.latitude;
                    const lon = pos.coords.longitude;
                    const landmarkInput = document.getElementById("landmarkInput");
                    const locationSelect = document.getElementById("locationSelect");
                    const addressInput = document.getElementById("addressInput");
                    const badge = document.getElementById("mapCoordinatesBadge");

                    const locStr = "GPS: " + lat.toFixed(4) + ", " + lon.toFixed(4);
                    if (landmarkInput) landmarkInput.value = locStr;
                    if (locationSelect) locationSelect.value = locStr;
                    if (addressInput) addressInput.value = "Live GPS Location (" + lat.toFixed(5) + " N, " + lon.toFixed(5) + " E)";
                    if (badge) badge.textContent = "Live GPS (" + lat.toFixed(4) + "°, " + lon.toFixed(4) + "°)";

                    if (leafletMap) {
                        leafletMap.setView([lat, lon], 14);
                        if (userMarker) userMarker.setLatLng([lat, lon]);
                        else userMarker = L.marker([lat, lon]).addTo(leafletMap);
                        userMarker.bindPopup("<b>📍 Your Current Location</b><br>Lat: " + lat.toFixed(4) + ", Lon: " + lon.toFixed(4)).openPopup();
                    }
                    showStatus("Live GPS coordinates locked successfully!", "success");
                },
                function (err) {
                    console.warn("GPS Geolocation error:", err);
                    showStatus("Could not acquire GPS: " + (err.message || "Location permission denied"), "danger");
                },
                { enableHighAccuracy: true, timeout: 8000 }
            );
        });
    }

    if (searchForm) {
        searchForm.addEventListener("submit", function (e) {
            e.preventDefault();
            performProviderSearch();
        });
    }

    if (findProvidersBtn) {
        findProvidersBtn.addEventListener("click", function (e) {
            e.preventDefault();
            performProviderSearch();
        });
    }

    function performProviderSearch() {
        const serviceSelect = document.getElementById("serviceSelect");
        const landmarkInput = document.getElementById("landmarkInput");
        const addressInput = document.getElementById("addressInput");
        const locationSelect = document.getElementById("locationSelect");
        const radiusSelect = document.getElementById("radiusSelect");
        const timeInput = document.getElementById("timeInput");

        const service = serviceSelect ? serviceSelect.value : "";
        let landmark = landmarkInput ? landmarkInput.value.trim() : "";
        let address = addressInput ? addressInput.value.trim() : "";
        if (!landmark && locationSelect && locationSelect.value) {
            landmark = locationSelect.value.trim();
        }
        if (!landmark && address) {
            landmark = address;
        }

        const radius = radiusSelect ? radiusSelect.value : "5";
        const requestedTime = timeInput ? timeInput.value : "11:00";
        const isEmergency = emergencyToggle ? emergencyToggle.checked : false;

        if (!service) {
            showStatus("Please select a service type.", "danger");
            return;
        }
        if (!landmark && !address) {
            showStatus("Please enter your landmark or street address.", "danger");
            return;
        }

        const displayLoc = landmark + (address && address !== landmark ? " (" + address + ")" : "");

        // Show loading state with sleek indicator
        showStatus("Searching for verified providers offering " + service + " near " + displayLoc + " within " + radius + " km...", "info");
        resultsContainer.innerHTML = 
            "<div style='text-align: center; padding: 3rem 1rem; color: var(--text-muted);'>" +
            "  <div style='display: inline-block; width: 36px; height: 36px; border: 3px solid rgba(79, 70, 229, 0.2); border-radius: 50%; border-top-color: var(--primary); animation: spin 0.8s linear infinite; margin-bottom: 1rem;'></div>" +
            "  <p style='font-size: 1rem; font-weight: 600; color: var(--secondary);'>Calculating Haversine GPS Distance & Allocating Best Candidates...</p>" +
            "</div>";

        // Build query URL for AJAX endpoint
        const params = new URLSearchParams({
            service: service,
            location: landmark,
            landmark: landmark,
            address: address,
            radius: radius,
            requestedTime: requestedTime,
            isEmergency: isEmergency ? "true" : "false"
        });

        // Determine context root path dynamically
        let contextPath = window.location.pathname;
        let slashIdx = contextPath.indexOf("/", 1);
        let apiBase = (slashIdx !== -1) ? contextPath.substring(0, slashIdx + 1) : "/";
        if (!apiBase.endsWith("/")) apiBase += "/";

        fetch(apiBase + "api/find-providers?" + params.toString(), {
            method: "GET",
            headers: {
                "Accept": "application/json"
            }
        })
        .then(function (response) {
            if (!response.ok) {
                throw new Error("Network response was not ok: " + response.statusText);
            }
            return response.json();
        })
        .then(function (data) {
            renderProviderCards(data, service, landmark, address, requestedTime, isEmergency);
            updateMap(data, landmark, parseFloat(radius));
        })
        .catch(function (error) {
            console.error("AJAX search failed:", error);
            showStatus("Failed to find providers. Please check backend connection.", "danger");
            resultsContainer.innerHTML = "";
        });
    }

    /**
     * Updates Leaflet Map with search location, radius circle, and provider pins.
     */
    function updateMap(data, landmarkName, radiusKm) {
        if (!leafletMap) return;

        const uLat = (data && data.userLat) ? data.userLat : 11.0168;
        const uLon = (data && data.userLon) ? data.userLon : 76.9558;

        leafletMap.setView([uLat, uLon], 13);

        if (userMarker) {
            userMarker.setLatLng([uLat, uLon]);
        } else {
            userMarker = L.marker([uLat, uLon]).addTo(leafletMap);
        }
        userMarker.bindPopup("<b>📍 Target Location</b><br>" + landmarkName).openPopup();

        // Update radius circle
        if (radiusCircle) {
            radiusCircle.setLatLng([uLat, uLon]);
            radiusCircle.setRadius(radiusKm * 1000);
        } else {
            radiusCircle = L.circle([uLat, uLon], {
                radius: radiusKm * 1000,
                color: "#4f46e5",
                fillColor: "#6366f1",
                fillOpacity: 0.12,
                weight: 2
            }).addTo(leafletMap);
        }

        // Clear and redraw provider markers
        if (providerMarkersLayer) {
            providerMarkersLayer.clearLayers();
        } else {
            providerMarkersLayer = L.layerGroup().addTo(leafletMap);
        }

        if (data && data.providers && data.providers.length > 0) {
            const bounds = L.latLngBounds([[uLat, uLon]]);
            data.providers.forEach(function (p) {
                if (p.latitude && p.longitude) {
                    bounds.extend([p.latitude, p.longitude]);
                    const marker = L.circleMarker([p.latitude, p.longitude], {
                        radius: 8,
                        fillColor: "#10b981",
                        color: "#ffffff",
                        weight: 2,
                        opacity: 1,
                        fillOpacity: 0.95
                    });
                    marker.bindPopup(
                        "<strong>👷 " + p.name + "</strong><br>" +
                        "🛠 " + (p.serviceName || "") + "<br>" +
                        "📍 Distance: " + p.distance + " km<br>" +
                        "📞 Phone: " + p.phone + "<br>" +
                        "<span style='color:#10b981;font-weight:700;'>● " + p.status + "</span>"
                    );
                    providerMarkersLayer.addLayer(marker);
                }
            });
            leafletMap.fitBounds(bounds, { padding: [30, 30] });
        }
    }

    /**
     * Dynamically builds DOM elements for suitable providers.
     * Uses document.createElement() strictly per Java Web Tech requirements.
     */
    function renderProviderCards(data, selectedService, selectedLandmark, selectedAddress, selectedTime, isEmergency) {
        // Clear previous results
        resultsContainer.innerHTML = "";

        if (!data || data.status === "empty" || !data.providers || data.providers.length === 0) {
            showStatus(data.message || "No suitable providers found within the selected radius.", "warning");
            const emptyNotice = document.createElement("div");
            emptyNotice.className = "alert alert-warning";
            emptyNotice.innerHTML = "<span>⚠️</span><span>No active service providers located within your selected radius. Try expanding search radius to 10 km or 15 km.</span>";
            resultsContainer.appendChild(emptyNotice);
            return;
        }

        showStatus(data.message, "success");

        const grid = document.createElement("div");
        grid.className = "providers-grid";

        data.providers.forEach(function (provider) {
            // 1. Create outer card
            const card = document.createElement("div");
            card.className = "provider-card";
            card.setAttribute("data-provider-id", provider.providerId);

            // 2. Card Header (Name & Status Badge)
            const header = document.createElement("div");
            header.className = "provider-header";

            const nameWrapper = document.createElement("div");
            nameWrapper.style.display = "flex";
            nameWrapper.style.alignItems = "center";
            nameWrapper.style.gap = "0.6rem";

            // Provider Avatar with initials
            const avatar = document.createElement("div");
            avatar.style.width = "40px";
            avatar.style.height = "40px";
            avatar.style.borderRadius = "10px";
            avatar.style.background = "linear-gradient(135deg, #4f46e5 0%, #06b6d4 100%)";
            avatar.style.color = "white";
            avatar.style.fontWeight = "800";
            avatar.style.fontSize = "1rem";
            avatar.style.display = "flex";
            avatar.style.alignItems = "center";
            avatar.style.justifyContent = "center";
            const initials = provider.name ? provider.name.split(" ").map(function(n) { return n[0]; }).join("").substring(0, 2) : "SP";
            avatar.textContent = initials;

            const nameDetails = document.createElement("div");
            const nameEl = document.createElement("div");
            nameEl.className = "provider-name";
            nameEl.textContent = provider.name;

            const ratingEl = document.createElement("div");
            ratingEl.style.fontSize = "0.75rem";
            ratingEl.style.color = "#d97706";
            ratingEl.style.fontWeight = "700";
            ratingEl.textContent = "★ 4.9 (Verified)";

            nameDetails.appendChild(nameEl);
            nameDetails.appendChild(ratingEl);

            nameWrapper.appendChild(avatar);
            nameWrapper.appendChild(nameDetails);

            const badge = document.createElement("span");
            badge.className = "badge " + (provider.status === "AVAILABLE" ? "badge-available" : "badge-busy");
            badge.textContent = provider.status;

            header.appendChild(nameWrapper);
            header.appendChild(badge);

            // 3. Service Subtitle Pill
            const serviceEl = document.createElement("div");
            serviceEl.className = "provider-service";
            serviceEl.textContent = "🛠 " + (provider.serviceName || selectedService);

            // 4. Provider Meta Information Box & Fare Calculation
            const baseFee = 200.0;
            const distCharge = (provider.distance || 1.0) * 20.0;
            const emCharge = isEmergency ? 150.0 : 0.0;
            const subtotal = baseFee + distCharge + emCharge;
            const totalBill = (subtotal * 1.18).toFixed(2);

            const meta = document.createElement("div");
            meta.className = "provider-meta";

            const distanceDiv = document.createElement("div");
            distanceDiv.innerHTML = "📍 Distance: <span class='distance-highlight'>" + provider.distance + " km</span>";

            const hoursDiv = document.createElement("div");
            hoursDiv.innerHTML = "⏰ Hours: <strong>" + provider.availableFrom + " - " + provider.availableUntil + "</strong>";

            const phoneDiv = document.createElement("div");
            phoneDiv.innerHTML = "📞 Contact: <strong>" + (provider.phone || "Verified") + "</strong>";

            const fareDiv = document.createElement("div");
            fareDiv.innerHTML = "💰 Est. Bill: <strong style='color: var(--success);'>₹" + totalBill + "</strong>" + 
                                (isEmergency ? " <span class='badge badge-emergency' style='font-size: 0.65rem; padding: 0.1rem 0.35rem;'>SOS</span>" : "");

            meta.appendChild(distanceDiv);
            meta.appendChild(hoursDiv);
            meta.appendChild(phoneDiv);
            meta.appendChild(fareDiv);

            // 5. Booking Action Form & Button
            const actionForm = document.createElement("form");
            actionForm.method = "POST";
            actionForm.action = "booking";

            const inputProviderId = document.createElement("input");
            inputProviderId.type = "hidden";
            inputProviderId.name = "providerId";
            inputProviderId.value = provider.providerId;

            const inputServiceName = document.createElement("input");
            inputServiceName.type = "hidden";
            inputServiceName.name = "serviceName";
            inputServiceName.value = selectedService;

            const fullLocation = selectedLandmark + (selectedAddress ? " (" + selectedAddress + ")" : "");

            const inputLocation = document.createElement("input");
            inputLocation.type = "hidden";
            inputLocation.name = "locationName";
            inputLocation.value = fullLocation;

            const inputLandmark = document.createElement("input");
            inputLandmark.type = "hidden";
            inputLandmark.name = "landmark";
            inputLandmark.value = selectedLandmark;

            const inputAddress = document.createElement("input");
            inputAddress.type = "hidden";
            inputAddress.name = "address";
            inputAddress.value = selectedAddress;

            const inputDistance = document.createElement("input");
            inputDistance.type = "hidden";
            inputDistance.name = "distance";
            inputDistance.value = provider.distance;

            const inputTime = document.createElement("input");
            inputTime.type = "hidden";
            inputTime.name = "requestedTime";
            inputTime.value = selectedTime;

            const inputEmergency = document.createElement("input");
            inputEmergency.type = "hidden";
            inputEmergency.name = "isEmergency";
            inputEmergency.value = isEmergency ? "true" : "false";

            const requestBtn = document.createElement("button");
            requestBtn.type = "submit";
            requestBtn.className = "btn btn-primary btn-block request-service request-service-btn";
            requestBtn.innerHTML = "REQUEST SERVICE →";

            actionForm.appendChild(inputProviderId);
            actionForm.appendChild(inputServiceName);
            actionForm.appendChild(inputLocation);
            actionForm.appendChild(inputLandmark);
            actionForm.appendChild(inputAddress);
            actionForm.appendChild(inputDistance);
            actionForm.appendChild(inputTime);
            actionForm.appendChild(inputEmergency);
            actionForm.appendChild(requestBtn);

            // Assemble complete card
            card.appendChild(header);
            card.appendChild(serviceEl);
            card.appendChild(meta);
            card.appendChild(actionForm);

            grid.appendChild(card);
        });

        resultsContainer.appendChild(grid);
    }

    function showStatus(message, type) {
        if (!statusAlert) return;
        statusAlert.className = "alert alert-" + type;
        statusAlert.innerHTML = (type === "success" ? "✓ " : type === "info" ? "ℹ️ " : "⚠️ ") + message;
        statusAlert.style.display = "flex";
    }
});

// Keyframe helper for dynamic spinner
const styleSheet = document.createElement("style");
styleSheet.innerText = "@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }";
document.head.appendChild(styleSheet);
