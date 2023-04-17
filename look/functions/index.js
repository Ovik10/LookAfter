const functions = require("firebase-functions");
const admin = require("firebase-admin");

const firebaseConfig = {
  apiKey: "AIzaSyApJA5ylgzutGOWda4oyG-FK8O282Pa6LI",
  authDomain: "lookafter-dae81.firebaseapp.com",
  projectId: "lookafter-dae81",
  storageBucket: "lookafter-dae81.appspot.com",
  messagingSenderId: "569161177650",
  appId: "1:569161177650:android:a7dcf44172e5af4e7d7a2b",
};

admin.initializeApp(firebaseConfig);

exports.createUserInFirestore = functions.auth.user().onCreate(async (user) => {
  const {email, uid} = user;
  const userDocRef = admin.firestore().collection("users").doc(uid);
  await userDocRef.set({
    email: email,
    contacts: [],
  });
});
