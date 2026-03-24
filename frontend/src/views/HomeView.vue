<script setup lang="ts">
import { useRouter } from 'vue-router'
import UserInfo from '@/components/UserInfo.vue'
import LoginUser from '../components/LoginUser.vue'
import store from '../store'
import type { User } from '@/types/user'
import Toast from 'primevue/toast'
import Button from 'primevue/button'
import { useToast } from 'primevue/usetoast'

const router = useRouter()
const toast = useToast()

const onLogout = (user: User) => {
  toast.add({
    severity: 'success',
    summary: `Goodbye, ${user.full_name}!`,
    detail: `You have successfully logged out.`,
    life: 3000
  })
  store.clearUser()
}

const goToRegister = () => {
  router.push('/register')
}

const goToDashboard = () => {
  router.push('/dashboard')
}
</script>

<template>
  <main class="main-container">
    <Toast />
    
    <!-- Header -->
    <div class="header fade-in-up">
      <div class="logo-container">
        <i class="pi pi-building logo-icon"></i>
        <h1 class="title">Simple Bank</h1>
      </div>
      <p class="subtitle">Your Trusted Banking Partner</p>
    </div>

    <!-- Content -->
    <div class="content-container slide-in-left">
      <UserInfo v-if="store.state.user" :user="store.state.user" @logout="onLogout" />
      <LoginUser v-else />
      
      <!-- Action Links -->
      <div v-if="!store.state.user" class="action-links">
        <p>Don't have an account?</p>
        <Button 
          label="Create Account" 
          icon="pi pi-user-plus"
          link
          @click="goToRegister"
          class="link-button"
        />
      </div>
      
      <div v-else class="action-links">
        <Button 
          label="Go to Dashboard" 
          icon="pi pi-th-large"
          @click="goToDashboard"
          class="dashboard-button"
        />
      </div>
    </div>

    <!-- Footer -->
    <div class="footer fade-in-up">
      <p>Powered by Go + gRPC + Vue 3</p>
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

.action-links {
  margin-top: 2rem;
  text-align: center;
  color: white;
}

.action-links p {
  margin-bottom: 0.5rem;
  font-size: 0.95rem;
}

.link-button {
  font-size: 1.1rem !important;
  color: white !important;
  font-weight: 600 !important;
}

.link-button:hover {
  text-decoration: underline !important;
}

.dashboard-button {
  width: 100%;
  padding: 0.75rem;
  font-size: 1.1rem;
  font-weight: 600;
  border-radius: 10px;
  transition: all 0.3s ease;
}

.dashboard-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.footer {
  margin-top: 3rem;
  text-align: center;
  color: rgba(255, 255, 255, 0.7);
  font-size: 0.9rem;
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
