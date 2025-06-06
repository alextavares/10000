// Script de teste automatizado para HabitAI
// Sessão 1: Autenticação e Onboarding

class HabitAITestSession1 {
  constructor() {
    this.results = {
      session: "Sessão 1: Autenticação e Onboarding",
      startTime: new Date().toISOString(),
      tests: []
    };
  }

  async runTests() {
    console.log("🚀 Iniciando testes da Sessão 1...");
    
    // Test 1: Verificar carregamento inicial
    await this.testInitialLoad();
    
    // Test 2: Verificar tela de login
    await this.testLoginScreen();
    
    // Test 3: Testar login com credenciais inválidas
    await this.testInvalidLogin();
    
    // Test 4: Testar campos obrigatórios
    await this.testRequiredFields();
    
    // Test 5: Testar link de recuperação de senha
    await this.testPasswordRecovery();
    
    // Test 6: Testar navegação para registro
    await this.testNavigateToRegister();
    
    this.saveResults();
  }

  async testInitialLoad() {
    const test = {
      name: "Carregamento Inicial",
      status: "pending",
      steps: []
    };

    try {
      // Verificar se o loading desapareceu
      const loadingElement = document.getElementById('loading');
      if (loadingElement && loadingElement.style.display !== 'none') {
        test.steps.push("❌ Loading ainda visível após carregamento");
        test.status = "failed";
      } else {
        test.steps.push("✅ Loading removido corretamente");
        test.status = "passed";
      }
      
      // Verificar se há elementos Flutter renderizados
      const flutterView = document.querySelector('flt-glass-pane');
      if (flutterView) {
        test.steps.push("✅ Flutter View renderizada");
      } else {
        test.steps.push("❌ Flutter View não encontrada");
        test.status = "failed";
      }
    } catch (error) {
      test.status = "error";
      test.error = error.message;
    }

    this.results.tests.push(test);
    console.log(`Test: ${test.name} - ${test.status}`);
  }

  async testLoginScreen() {
    const test = {
      name: "Tela de Login",
      status: "pending",
      steps: []
    };

    try {
      // Aguardar um pouco para a tela carregar
      await this.wait(2000);
      
      // Verificar elementos da tela de login
      const elements = {
        emailField: this.findByText('Email') || this.findByText('E-mail'),
        passwordField: this.findByText('Senha') || this.findByText('Password'),
        loginButton: this.findByText('Entrar') || this.findByText('Login'),
        googleButton: this.findByText('Google') || this.findByText('Entrar com Google')
      };

      for (const [key, element] of Object.entries(elements)) {
        if (element) {
          test.steps.push(`✅ ${key} encontrado`);
        } else {
          test.steps.push(`❌ ${key} não encontrado`);
          test.status = "failed";
        }
      }

      if (test.status !== "failed") {
        test.status = "passed";
      }
    } catch (error) {
      test.status = "error";
      test.error = error.message;
    }

    this.results.tests.push(test);
    console.log(`Test: ${test.name} - ${test.status}`);
  }

  async testInvalidLogin() {
    const test = {
      name: "Login com Credenciais Inválidas",
      status: "pending",
      steps: []
    };

    try {
      // Simular entrada de dados inválidos
      test.steps.push("🔄 Simulando login com credenciais inválidas...");
      
      // Aqui seria implementada a lógica de teste real
      test.steps.push("⏸️ Teste aguardando implementação completa");
      test.status = "pending";
    } catch (error) {
      test.status = "error";
      test.error = error.message;
    }

    this.results.tests.push(test);
    console.log(`Test: ${test.name} - ${test.status}`);
  }

  async testRequiredFields() {
    const test = {
      name: "Campos Obrigatórios",
      status: "pending",
      steps: []
    };

    try {
      test.steps.push("🔄 Verificando validação de campos obrigatórios...");
      test.steps.push("⏸️ Teste aguardando implementação completa");
      test.status = "pending";
    } catch (error) {
      test.status = "error";
      test.error = error.message;
    }

    this.results.tests.push(test);
    console.log(`Test: ${test.name} - ${test.status}`);
  }

  async testPasswordRecovery() {
    const test = {
      name: "Recuperação de Senha",
      status: "pending",
      steps: []
    };

    try {
      const forgotPasswordLink = this.findByText('Esqueceu a senha?') || 
                                  this.findByText('Forgot password?');
      
      if (forgotPasswordLink) {
        test.steps.push("✅ Link de recuperação de senha encontrado");
        test.status = "passed";
      } else {
        test.steps.push("❌ Link de recuperação de senha não encontrado");
        test.status = "failed";
      }
    } catch (error) {
      test.status = "error";
      test.error = error.message;
    }

    this.results.tests.push(test);
    console.log(`Test: ${test.name} - ${test.status}`);
  }

  async testNavigateToRegister() {
    const test = {
      name: "Navegação para Registro",
      status: "pending",
      steps: []
    };

    try {
      const registerLink = this.findByText('Criar conta') || 
                          this.findByText('Registrar') ||
                          this.findByText('Sign up');
      
      if (registerLink) {
        test.steps.push("✅ Link para registro encontrado");
        test.status = "passed";
      } else {
        test.steps.push("❌ Link para registro não encontrado");
        test.status = "failed";
      }
    } catch (error) {
      test.status = "error";
      test.error = error.message;
    }

    this.results.tests.push(test);
    console.log(`Test: ${test.name} - ${test.status}`);
  }

  // Métodos auxiliares
  findByText(text) {
    const elements = document.querySelectorAll('*');
    for (const element of elements) {
      if (element.textContent && element.textContent.includes(text)) {
        return element;
      }
    }
    return null;
  }

  async wait(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  saveResults() {
    this.results.endTime = new Date().toISOString();
    console.log("\n📊 Resultados dos Testes:");
    console.log(JSON.stringify(this.results, null, 2));
    
    // Salvar no localStorage para recuperação posterior
    localStorage.setItem('habitai_test_session1', JSON.stringify(this.results));
  }
}

// Executar testes quando a página estiver carregada
if (document.readyState === 'complete') {
  new HabitAITestSession1().runTests();
} else {
  window.addEventListener('load', () => {
    new HabitAITestSession1().runTests();
  });
}
