// Script de diagnóstico para testar criação de hábitos
// Cole este código no console do navegador após fazer login

async function testarCriacaoHabito() {
  console.log('=== TESTE DE CRIAÇÃO DE HÁBITO ===');
  
  // 1. Verificar se o usuário está autenticado
  const auth = firebase.auth();
  const user = auth.currentUser;
  
  if (!user) {
    console.error('❌ Usuário não está autenticado!');
    return;
  }
  
  console.log('✅ Usuário autenticado:', user.uid);
  console.log('   Email:', user.email || 'Anônimo');
  
  // 2. Tentar criar um hábito de teste
  const db = firebase.firestore();
  const habitId = 'test-' + Date.now();
  
  const testHabit = {
    id: habitId,
    title: 'Hábito de Teste',
    description: 'Criado via console para teste',
    category: 'Saúde',
    icon: '🏃',
    color: '#4CAF50',
    priority: 'Normal',
    frequency: 'daily',
    startDate: new Date().toISOString(),
    trackingType: 'simNao',
    userId: user.uid,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    completionHistory: {},
    dailyProgress: {},
    streak: 0,
    longestStreak: 0,
    totalCompletions: 0,
    notificationsEnabled: false
  };
  
  console.log('📝 Tentando criar hábito:', testHabit);
  
  try {
    await db.collection('users').doc(user.uid).collection('habits').doc(habitId).set(testHabit);
    console.log('✅ Hábito criado com sucesso!');
    
    // 3. Tentar ler o hábito criado
    const doc = await db.collection('users').doc(user.uid).collection('habits').doc(habitId).get();
    
    if (doc.exists) {
      console.log('✅ Hábito lido com sucesso:', doc.data());
      
      // 4. Deletar o hábito de teste
      await doc.ref.delete();
      console.log('🗑️ Hábito de teste deletado');
    } else {
      console.error('❌ Hábito criado mas não pode ser lido');
    }
    
  } catch (error) {
    console.error('❌ Erro ao criar hábito:', error);
    console.error('   Código:', error.code);
    console.error('   Mensagem:', error.message);
    
    if (error.code === 'permission-denied') {
      console.error('   🔒 Problema de permissão no Firestore');
    }
  }
  
  // 5. Verificar configuração do Firebase
  console.log('\n=== CONFIGURAÇÃO FIREBASE ===');
  console.log('Project ID:', firebase.app().options.projectId);
  console.log('Auth Domain:', firebase.app().options.authDomain);
  
  console.log('\n=== FIM DO TESTE ===');
}

// Executar o teste
testarCriacaoHabito();
