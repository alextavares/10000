// Script para limpar TODOS os dados locais - Force Logout
// Execute no console do navegador ANTES de reiniciar

console.log('🔥 Limpando TODOS os dados do Firebase e aplicação...\n');

// Limpar tudo do localStorage
localStorage.clear();
console.log('✅ localStorage completamente limpo');

// Limpar sessionStorage
sessionStorage.clear();
console.log('✅ sessionStorage completamente limpo');

// Limpar TODOS os cookies
document.cookie.split(";").forEach(function(c) { 
    document.cookie = c.replace(/^ +/, "").replace(/=.*/, "=;expires=" + new Date().toUTCString() + ";path=/"); 
});
console.log('✅ Todos os cookies removidos');

// Limpar IndexedDB - especialmente Firebase
if (window.indexedDB) {
    // Listar todos os bancos de dados
    indexedDB.databases().then(databases => {
        console.log('🗄️ Removendo IndexedDB databases:');
        databases.forEach(db => {
            indexedDB.deleteDatabase(db.name);
            console.log(`  ✅ Removido: ${db.name}`);
        });
    }).catch(e => console.log('Erro ao listar databases:', e));
}

// Limpar cache do Service Worker
if ('serviceWorker' in navigator) {
    navigator.serviceWorker.getRegistrations().then(function(registrations) {
        for(let registration of registrations) {
            registration.unregister();
            console.log('✅ Service Worker removido');
        }
    });
}

// Limpar caches
if ('caches' in window) {
    caches.keys().then(names => {
        names.forEach(name => {
            caches.delete(name);
            console.log(`✅ Cache removido: ${name}`);
        });
    });
}

console.log('\n✨ Limpeza COMPLETA realizada!');
console.log('🚪 Agora FECHE TODAS as abas do localhost:5003');
console.log('⏰ Aguarde 5 segundos antes de abrir novamente');
