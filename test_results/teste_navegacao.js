// Script de teste rápido para navegação - HabitAI
// Execute este código no console do navegador (F12)

console.log('🚀 Iniciando teste de navegação...\n');

// Função para encontrar e clicar em elementos
function testarNavegacao() {
    const resultados = {
        navegacao: {},
        botoes: {},
        elementos: {}
    };

    // Testar abas de navegação
    console.log('📍 Testando navegação inferior...');
    const abas = ['Hábitos', 'Tarefas', 'Timer', 'Categorias'];
    
    abas.forEach(aba => {
        const elemento = Array.from(document.querySelectorAll('*')).find(el => 
            el.textContent === aba && !el.children.length
        );
        
        if (elemento) {
            console.log(`✅ Aba "${aba}" encontrada`);
            resultados.navegacao[aba] = true;
            
            // Simular clique (comentado para não navegar automaticamente)
            // elemento.click();
        } else {
            console.log(`❌ Aba "${aba}" não encontrada`);
            resultados.navegacao[aba] = false;
        }
    });

    // Procurar botão de adicionar
    console.log('\n🔍 Procurando botão de adicionar...');
    const botaoAdd = document.querySelector('button') || 
                     document.querySelector('[aria-label*="add"]') ||
                     document.querySelector('[aria-label*="adicionar"]');
    
    if (botaoAdd) {
        console.log('✅ Botão de adicionar encontrado');
        resultados.botoes.adicionar = true;
    } else {
        console.log('❌ Botão de adicionar não encontrado');
        resultados.botoes.adicionar = false;
    }

    // Procurar menu de perfil/logout
    console.log('\n👤 Procurando menu de perfil...');
    const menuPerfil = Array.from(document.querySelectorAll('*')).find(el => 
        el.textContent && (
            el.textContent.includes('Perfil') || 
            el.textContent.includes('Sair') ||
            el.textContent.includes('Logout') ||
            el.textContent.includes('Configurações')
        )
    );
    
    if (menuPerfil) {
        console.log('✅ Menu de perfil/logout encontrado');
        resultados.elementos.menuPerfil = true;
    } else {
        console.log('❓ Menu de perfil/logout não encontrado (pode estar em submenu)');
        resultados.elementos.menuPerfil = false;
    }

    // Contar elementos interativos
    const botoes = document.querySelectorAll('button').length;
    const links = document.querySelectorAll('a').length;
    const inputs = document.querySelectorAll('input').length;
    
    console.log('\n📊 Estatísticas da página:');
    console.log(`- Botões: ${botoes}`);
    console.log(`- Links: ${links}`);
    console.log(`- Campos de entrada: ${inputs}`);

    // Salvar resultados
    localStorage.setItem('habitai_nav_test', JSON.stringify(resultados));
    
    console.log('\n✨ Teste concluído!');
    console.log('💡 Dica: Clique manualmente em cada aba para testar a navegação');
    
    return resultados;
}

// Executar teste
testarNavegacao();

// Instruções para teste manual
console.log('\n📋 TESTE MANUAL SUGERIDO:');
console.log('1. Clique em "Hábitos" e verifique se a tela muda');
console.log('2. Clique em "Tarefas" e verifique se a tela muda');
console.log('3. Clique em "Timer" e verifique se a tela muda');
console.log('4. Clique em "Categorias" e verifique se a tela muda');
console.log('5. Clique no botão "+" e veja o que acontece');
console.log('6. Procure um menu (3 pontos ou ícone de perfil) para logout');
