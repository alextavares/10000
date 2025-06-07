/// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyAayN2swkuxNZRV_htDIKc9CUjgcxQJK4M",
  authDomain: "android-habitai.firebaseapp.com",
  projectId: "android-habitai",
  storageBucket: "android-habitai.firebasestorage.app",
  messagingSenderId: "258006613617",
  appId: "1:258006613617:web:97dd7ccb386841785465d0"
};

// Promise que resolve quando o Firebase estiver inicializado
window.firebaseReady = new Promise((resolve, reject) => {
  let attempts = 0;
  const maxAttempts = 10; // Tentar por 10 segundos no máximo

  function tryInitialize() {
    attempts++;
    try {
      if (typeof firebase !== 'undefined' && firebase.app) {
        // O Firebase SDK está carregado
        if (firebase.apps.length === 0) { // Inicializar apenas se não houver apps inicializados
            firebase.initializeApp(firebaseConfig);
            console.log("Firebase Web initialized successfully with compat mode");
        } else {
            console.log("Firebase Web already initialized");
        }

        // Verificar que Auth e Firestore estão disponíveis
        if (firebase.auth && firebase.firestore) {
          console.log("Firebase Auth and Firestore are available");
          
          // Configurações específicas do Firestore
          try {
            firebase.firestore().settings({
              cacheSizeBytes: firebase.firestore.CACHE_SIZE_UNLIMITED,
              ignoreUndefinedProperties: true
            });
            console.log("Firestore settings applied.");
          } catch (settingsError) {
            console.warn("Could not apply Firestore settings:", settingsError);
            // Continuar mesmo se as configurações falharem
          }
          resolve(); // Firebase está pronto
        } else {
          console.warn("Firebase Auth or Firestore not yet available. Retrying...");
          if (attempts < maxAttempts) {
            setTimeout(tryInitialize, 1000);
          } else {
            reject(new Error("Firebase Auth/Firestore not available after multiple attempts."));
          }
        }
      } else {
        console.warn("Firebase SDK not available yet. Retrying...");
        if (attempts < maxAttempts) {
          setTimeout(tryInitialize, 1000);
        } else {
          reject(new Error("Firebase SDK not available after multiple attempts."));
        }
      }
    } catch (e) {
      console.error("Error initializing Firebase:", e);
      reject(e); // Rejeitar a promise em caso de erro
    }
  }

  // Iniciar a primeira tentativa de inicialização
  // Esperar pelo DOMContentLoaded para garantir que os scripts do Firebase foram carregados
  if (document.readyState === "loading") {
    document.addEventListener('DOMContentLoaded', tryInitialize);
  } else {
    // O DOM já está carregado
    tryInitialize();
  }
});
