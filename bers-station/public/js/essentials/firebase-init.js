const firebaseConfig = {
    apiKey: "AIzaSyDSmy58A7qw9TUsJH4GB6mAIZabz1Gxeg4",
    authDomain: "database-4b12a.firebaseapp.com",
    databaseURL: "https://database-4b12a-default-rtdb.firebaseio.com",
    projectId: "database-4b12a",
    storageBucket: "database-4b12a.firebasestorage.app",
    messagingSenderId: "572052189881",
    appId: "1:572052189881:web:a8480b21a101572b55e168"
};

firebase.initializeApp(firebaseConfig);
const storage = firebase.storage();

firebase.auth().signInWithCustomToken(window.firebaseCustomToken)

