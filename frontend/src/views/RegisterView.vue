<script setup lang="ts">
import { useRouter } from 'vue-router'
import RegisterUser from '@/components/RegisterUser.vue'
import Toast from 'primevue/toast'
import Button from 'primevue/button'

const router = useRouter()

const goToLogin = () => {
  router.push('/')
}

const onRegistered = () => {
  setTimeout(() => {
    router.push('/')
  }, 2000)
}
</script>

<template>
  <main class="main-container">
    <Toast />
    
    <div class="header fade-in-up">
      <div class="logo-container">
        <i class="pi pi-building logo-icon"></i>
        <h1 class="title">Simple Bank</h1>
      </div>
      <p class="subtitle">Create Your Account</p>
    </div>

    <div class="content-container slide-in-left">
      <RegisterUser @registered="onRegistered" />
      
      <div class="back-to-login">
        <p>Already have an account?</p>
        <Button 
          label="Back to Login" 
          icon="pi pi-arrow-left"
          link
          @click="goToLogin"
        />
      </div>
    </div>
  </main>
</template>

<style scoped>
.main-container {
  min-height: 80vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 2rem;
}

.header {
  text-align: center;
  margin-bottom: 2rem;
}

.logo-container {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 0.5rem;
}

.logo-icon {
  font-size: 3rem;
  color: white;
  animation: float 3s ease-in-out infinite;
}

.title {
  font-size: 3rem;
  font-weight: 700;
  color: white;
  margin: 0;
  text-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.subtitle {
  font-size: 1.1rem;
  color: rgba(255, 255, 255, 0.9);
  font-weight: 300;
  letter-spacing: 1px;
}

.content-container {
  width: 100%;
  max-width: 500px;
  margin: 0 auto;
}

.back-to-login {
  margin-top: 2rem;
  text-align: center;
  color: white;
}

.back-to-login p {
  margin-bottom: 0.5rem;
  font-size: 0.95rem;
}

@media (max-width: 768px) {
  .title {
    font-size: 2rem;
  }
  
  .logo-icon {
    font-size: 2rem;
  }
  
  .subtitle {
    font-size: 1rem;
  }
}
</style>
