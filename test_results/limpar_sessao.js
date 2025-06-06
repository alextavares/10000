// Script para limpar sessão do HabitAI
// Execute este código no console do navegador ANTES de fechar a aba

console.log('🧹 Limpando dados de sessão do HabitAI...\n');

try {
    // Limpar localStorage
    const keysToRemove = [];
    for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && (key.includes('habit') || key.includes('auth') || key.includes('user') || key.includes('session'))) {
            keysToRemove.push(key);
        }
    }
    
    keysToRemove.forEach(key => {
        localStorage.removeItem(key);
        console.log(`✅ Removido: ${key}`);
    });
    
    // Limpar sessionStorage
    sessionStorage.clear();
    console.log('✅ SessionStorage limpo');
    
    // Limpar cookies (se possível)
    document.cookie.split(";").forEach(function(c) { 
        document.cookie = c.replace(/^ +/, "").replace(/=.*/, "=;expires=" + new Date().toUTCString() + ";path=/"); 
    });
    console.log('✅ Cookies limpos');
    
    // Limpar IndexedDB (se usado)
    if (window.indexedDB) {
        indexedDB.databases().then(databases => {
            databases.forEach(db => {
                if (db.name.includes('firebase') || db.name.includes('habit')) {
                    indexedDB.deleteDatabase(db.name);
                    console.log(`✅ IndexedDB removido: ${db.name}`);
                }
            });
        });
    }
    
    console.log('\n✨ Limpeza concluída!');
    console.log('📌 Agora feche esta aba e aguarde o restart do servidor');
    
} catch (error) {
    console.error('❌ Erro ao limpar dados:', error);
}
