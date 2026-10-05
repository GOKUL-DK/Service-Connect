/**
 * ServiceConnect - Live Booking Status Polling & In-App Notifications
 * Polls booking status via AJAX and provides instant visual feedback when
 * a provider accepts or completes the allocated job.
 * Also handles in-app live dispatch messaging and post-service ratings.
 */

document.addEventListener("DOMContentLoaded", function () {
    const bookingStatusEl = document.getElementById("liveBookingStatus");
    const bookingIdEl = document.getElementById("liveBookingId");
    const notificationBanner = document.getElementById("bookingNotificationBanner");
    const reviewCard = document.getElementById("reviewCard");

    if (!bookingStatusEl || !bookingIdEl) {
        return;
    }

    const bookingId = bookingIdEl.textContent.trim().replace(/\D/g, "");
    let currentStatus = bookingStatusEl.textContent.trim();

    // Fast, responsive background status polling
    function pollStatus() {
        if (!bookingId) return;
        fetch("api/booking-status?bookingId=" + encodeURIComponent(bookingId))
            .then(function (response) {
                return response.json();
            })
            .then(function (data) {
                if (data.status === "success" && data.bookingStatus) {
                    const newStatus = data.bookingStatus;
                    if (newStatus !== currentStatus) {
                        currentStatus = newStatus;
                        updateStatusUI(newStatus, data.providerName);
                    }
                    if (newStatus === "COMPLETED" || newStatus === "CANCELLED") {
                        clearInterval(pollInterval);
                    }
                }
            })
            .catch(function (err) {
                console.warn("Status poll error:", err);
            });
    }

    // Trigger immediate poll on load, then poll every 800ms for instant real-time feedback
    pollStatus();
    const pollInterval = setInterval(pollStatus, 800);

    function updateStatusUI(status, providerName) {
        bookingStatusEl.textContent = status;
        bookingStatusEl.className = "badge badge-" + status.toLowerCase();

        if (notificationBanner) {
            notificationBanner.style.display = "block";
            if (status === "ACCEPTED") {
                notificationBanner.className = "alert alert-success";
                notificationBanner.textContent = "✓ " + (providerName || "Provider") + " has accepted your service request!";
            } else if (status === "IN_PROGRESS") {
                notificationBanner.className = "alert alert-info";
                notificationBanner.textContent = "✓ Service has begun and is currently in progress.";
            } else if (status === "COMPLETED") {
                notificationBanner.className = "alert alert-success";
                notificationBanner.textContent = "✓ Service completed successfully. Thank you for using ServiceConnect!";
                if (reviewCard) reviewCard.style.display = "block";
            }
        }
    }

    // --- Live Chat Logic ---
    const chatContainer = document.getElementById("chatMessages");
    const chatInput = document.getElementById("chatInput");
    const sendChatBtn = document.getElementById("sendChatBtn");

    function loadChatMessages() {
        if (!bookingId || !chatContainer) return;
        fetch("api/chat?bookingId=" + encodeURIComponent(bookingId))
            .then(r => r.json())
            .then(messages => {
                if (!messages || messages.length === 0) {
                    chatContainer.innerHTML = "<div style='color: var(--text-muted); text-align: center; margin-top: 2rem;'>No messages yet. Send a note to your provider!</div>";
                    return;
                }
                chatContainer.innerHTML = "";
                messages.forEach(m => {
                    const isMe = m.senderRole === "CUSTOMER";
                    const bubble = document.createElement("div");
                    bubble.className = "chat-bubble " + (isMe ? "chat-bubble-me" : "chat-bubble-them");
                    bubble.innerHTML = "<strong>" + m.senderName + ":</strong> " + m.messageText + 
                                      "<div class='chat-bubble-meta'>" + (m.createdAt ? m.createdAt.substring(11, 16) : "") + "</div>";
                    chatContainer.appendChild(bubble);
                });
                chatContainer.scrollTop = chatContainer.scrollHeight;
            })
            .catch(e => console.warn(e));
    }

    function sendChatMessage() {
        if (!chatInput) return;
        const text = chatInput.value.trim();
        if (!text || !bookingId) return;

        const params = new URLSearchParams();
        params.append("bookingId", bookingId);
        params.append("message", text);

        fetch("api/chat", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: params.toString()
        })
        .then(r => r.json())
        .then(data => {
            if (data.status === "success") {
                chatInput.value = "";
                loadChatMessages();
            }
        });
    }

    if (sendChatBtn) {
        sendChatBtn.addEventListener("click", sendChatMessage);
    }
    if (chatInput) {
        chatInput.addEventListener("keydown", function (e) {
            if (e.key === "Enter") sendChatMessage();
        });
    }

    if (chatContainer) {
        loadChatMessages();
        setInterval(loadChatMessages, 2500);
    }

    // --- Star Rating & Review Logic ---
    window.setRating = function (val) {
        const ratingVal = document.getElementById("ratingValue");
        if (ratingVal) ratingVal.value = val;
        const stars = document.querySelectorAll("#starContainer span");
        stars.forEach((s, idx) => {
            s.style.color = (idx < val) ? "#fbbf24" : "#d1d5db";
        });
    };

    const submitReviewBtn = document.getElementById("submitReviewBtn");
    if (submitReviewBtn) {
        submitReviewBtn.addEventListener("click", function () {
            const ratingVal = document.getElementById("ratingValue");
            const reviewComment = document.getElementById("reviewComment");
            const rating = ratingVal ? ratingVal.value : "5";
            const comment = reviewComment ? reviewComment.value : "";

            const params = new URLSearchParams();
            params.append("bookingId", bookingId);
            params.append("rating", rating);
            params.append("comment", comment);

            fetch("api/review", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: params.toString()
            })
            .then(r => r.json())
            .then(data => {
                if (data.status === "success") {
                    reviewCard.innerHTML = "<div class='alert alert-success'>✓ Thank you! Your review has been saved.</div>";
                }
            });
        });
    }
});

