<script setup lang="ts">
import { useRouter } from 'vue-router'
import { computed } from 'vue'
import store from '@/store'
import Card from 'primevue/card'
import Button from 'primevue/button'
import Toast from 'primevue/toast'
import { useToast } from 'primevue/usetoast'

const router = useRouter()
const toast = useToast()

const user = computed(() => store.state.user)

const goToHome = () => {
  router.push('/home')
}

const logout = () => {
  toast.add({
    severity: 'success',
    summary: `Goodbye, ${user.value?.full_name}!`,
    detail: 'You have been logged out',
    life: 3000
  })
  store.clearUser()
  router.push('/')
}
</script>

<template>
  <main class="dashboard-container">
    <Toast />
    
    <!-- Header -->
    <div class="dashboard-header">
      <div class="header-content">
        <div class="logo-section">
          <i class="pi pi-building"></i>
          <h1>Simple Bank</h1>
        </div>
        <div class="user-section">
          <span class="welcome-text">Welcome, {{ user?.full_name }}</span>
          <Button 
            icon="pi pi-sign-out" 
            label="Logout"
            outlined
            severity="danger"
            @click="logout"
          />
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="dashboard-content">
      <h2 class="section-title">Dashboard</h2>
      
      <div class="features-grid">
        <!-- Profile Card -->
        <Card class="feature-card" @click="goToHome">
          <template #header>
            <div class="card-icon">
              <i class="pi pi-user"></i>
            </div>
          </template>
          <template #title>My Profile</template>
          <template #content>
            <p>View and manage your personal information</p>
          </template>
        </Card>

        <!-- Accounts Card -->
        <Card class="feature-card coming-soon">
          <template #header>
            <div class="card-icon">
              <i class="pi pi-wallet"></i>
            </div>
          </template>
          <template #title>My Accounts</template>
          <template #content>
            <p>Manage your bank accounts</p>
            <span class="badge">Coming Soon</span>
          </template>
        </Card>

        <!-- Transfer Card -->
        <Card class="feature-card coming-soon">
          <template #header>
            <div class="card-icon">
              <i class="pi pi-send"></i>
            </div>
          </template>
          <template #title>Transfer Money</template>
          <template #content>
            <p>Send money to other accounts</p>
            <span class="badge">Coming Soon</span>
          </template>
        </Card>

        <!-- History Card -->
        <Card class="feature-card coming-soon">
          <template #header>
            <div class="card-icon">
              <i class="pi pi-history"></i>
            </div>
          </template>
          <template #title>Transaction History</template>
          <template #content>
            <p>View your transaction history</p>
            <span class="badge">Coming Soon</span>
          </template>
        </Card>
      </div>
    </div>
  </main>
</template>

<style scoped>
.dashboard-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.dashboard-header {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  padding: 1.5rem 2rem;
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 1rem;
  color: white;
}

.logo-section i {
  font-size: 2rem;
}

.logo-section h1 {
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0;
}

.user-section {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.welcome-text {
  color: white;
  font-weight: 500;
}

.dashboard-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 3rem 2rem;
}

.section-title {
  color: white;
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 2rem;
  text-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
}

.feature-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
}

.feature-card:not(.coming-soon):hover {
  transform: translateY(-5px);
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.3);
}

.feature-card.coming-soon {
  opacity: 0.7;
  cursor: not-allowed;
}

.card-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  margin: -1rem -1rem 0 -1rem;
  border-radius: 15px 15px 0 0;
}

.card-icon i {
  font-size: 3rem;
  color: white;
}

.badge {
  display: inline-block;
  background: rgba(251, 146, 60, 0.2);
  color: #ea580c;
  padding: 0.3rem 0.6rem;
  border-radius: 5px;
  font-size: 0.75rem;
  font-weight: 600;
  margin-top: 0.5rem;
}

@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }

  .user-section {
    flex-direction: column;
    gap: 0.5rem;
  }

  .section-title {
    font-size: 2rem;
  }

  .features-grid {
    grid-template-columns: 1fr;
  }
}
</style>
