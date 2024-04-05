const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

// Cloud Function to create a user document in Firestore upon user creation
exports.createUserInFirestore = functions.auth.user().onCreate(async (user) => {
    const { email, uid } = user;
    const userDocRef = admin.firestore().collection('users').doc(uid);
    await userDocRef.set({
        email: email,
        contacts: [],
    });
    console.log(`User document created in Firestore for ${uid}.`);
});

// Cloud Function to delete user data from Realtime Database, Firestore, and Storage upon user deletion
exports.deleteUserData = functions.auth.user().onDelete(async (user) => {
    const userId = user.uid;
    const batch = admin.firestore().batch();

    try {
        // Delete user data from Realtime Database
        const databaseRef = admin.database().ref(`users/${userId}`);
        await databaseRef.remove();
        console.log(`User data removed from Realtime Database for ${userId}.`);

        // Delete user data from Firestore
        const firestoreRef = admin.firestore().collection('users').doc(userId);
        batch.delete(firestoreRef);
        console.log(`User document deleted from Firestore for ${userId}.`);

        // Delete user data from Storage
        const storageRef = admin.storage().bucket().file(`profile_images/${userId}.jpg`);
        await storageRef.delete();
        console.log(`Profile image deleted from Storage for ${userId}.`);

        // Commit batch operation for Firestore
        await batch.commit();
        console.log(`Batch operation committed for Firestore for ${userId}.`);

        console.log(`User data for ${userId} deleted successfully.`);
    } catch (error) {
        console.error(`Error deleting user data for ${userId}:`, error);
    }
});
