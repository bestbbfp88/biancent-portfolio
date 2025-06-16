const firebaseConfig = {
    // Add from Firebase
};

firebase.initializeApp(firebaseConfig);
const storage = firebase.storage();

firebase.auth().signInWithCustomToken(window.firebaseCustomToken)

