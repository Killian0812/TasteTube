importScripts(
  "https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js"
);

firebase.initializeApp({
  apiKey: "AIzaSyBMv4uzsp7IEL-fsJYnIDC6SIkHSel5638",
  appId: "1:885591194987:web:7c557b8dc5a002ef91a02e",
  messagingSenderId: "885591194987",
  projectId: "taste-tube",
  authDomain: "taste-tube.firebaseapp.com",
  storageBucket: "taste-tube.appspot.com",
});

// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});
