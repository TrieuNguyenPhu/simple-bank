<script setup lang="ts">
import InputGroup from 'primevue/inputgroup'
import InputGroupAddon from 'primevue/inputgroupaddon'
import FloatLabel from 'primevue/floatlabel'
import InputText from 'primevue/inputtext'
import Button from 'primevue/button'
import Card from 'primevue/card'
import { useToast } from 'primevue/usetoast'
import { useRouter } from 'vue-router'
import { ref } from 'vue'
import axios from 'axios'
import type { User } from '@/types/user'
import store from '@/store'
import API_BASE_URL from '@/api'

interface LoginResponse {
  user: User
  access_token: string
  refresh_token: string
}

const username = ref<string>('')
const password = ref<string>('')
const errorMessage = ref<string>('')
const loading = ref<boolean>(false)
const toast = useToast()
const router = useRouter()

const handleLogin = async () => {
  if (!username.value || !password.value) {
    toast.add({
      severity: 'warn',
      summary: 'Validation Error',
      detail: 'Please enter both username and password',
      life: 3000
    })
    return
  }

  loading.value = true
  
  try {
    const response = await axios.post<LoginResponse>(
      `${API_BASE_URL}/v1/login_user`,
      {
        username: username.value,
        password: password.value
      },
      {
        headers: {
          'Content-Type': 'application/json',
          Authorization: 'none'
        }
      }
    )

    store.setUser(response.data.user, response.data.access_token, response.data.refresh_token)
    toast.add({
      severity: 'success',
      summary: `Welcome back, ${response.data.user.full_name}!`,
      detail: `Successfully logged in`,
      life: 2000
    })
    
    // Redirect to dashboard after successful login
    setTimeout(() => {
      router.push('/dashboard')
    }, 500)
  } catch (error: any) {
    if (error.response && error.response.status === 404) {
      errorMessage.value = error.response.data.message
    } else {
      errorMessage.value = 'Invalid username or password'
    }

    toast.add({
      severity: 'error',
      summary: 'Login Failed',
      detail: errorMessage.value,
      life: 3000
    })
  } finally {
    loading.value = false
  }
}

const handleKeyPress = (event: KeyboardEvent) => {
  if (event.key === 'Enter') {
    handleLogin()
  }
}
</script>

<template>
  <Card class="login-card">
    <template #header>
      <div class="card-header">
        <div class="avatar-circle">
          <i class="pi pi-user"></i>
        </div>
        <h2>Sign In</h2>
        <p>Enter your credentials to access your account</p>
      </div>
    </template>

    <template #content>
      <div class="login-form">
        <div class="input-wrapper">
          <InputGroup>
            <InputGroupAddon>
              <i class="pi pi-user"></i>
            </InputGroupAddon>
            <FloatLabel>
              <InputText 
                id="username" 
                v-model="username" 
                class="input-field"
                @keypress="handleKeyPress"
              />
              <label for="username">Username</label>
            </FloatLabel>
          </InputGroup>
        </div>

        <div class="input-wrapper">
          <InputGroup>
            <InputGroupAddon>
              <i class="pi pi-lock"></i>
            </InputGroupAddon>
            <FloatLabel>
              <InputText 
                id="password" 
                type="password" 
                v-model="password" 
                class="input-field"
                @keypress="handleKeyPress"
              />
              <label for="password">Password</label>
            </FloatLabel>
          </InputGroup>
        </div>

        <Button 
          label="Sign In" 
          icon="pi pi-sign-in"
          :loading="loading"
          @click="handleLogin" 
          class="login-button"
          severity="success"
        />

        <div class="demo-users">
          <p class="demo-title">Demo Users:</p>
          <div class="demo-list">
            <span class="demo-user">alice / password123</span>
            <span class="demo-user">bob / password123</span>
            <span class="demo-user">demo / demo123456</span>
          </div>
        </div>
      </div>
    </template>
  </Card>
</template>

<style scoped>
.login-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  overflow: hidden;
}

.card-header {
  text-align: center;
  padding: 2rem 2rem 0 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  margin: -1rem -1rem 0 -1rem;
  padding-bottom: 2rem;
}

.avatar-circle {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1rem auto;
  border: 3px solid rgba(255, 255, 255, 0.3);
}

.avatar-circle i {
  font-size: 2rem;
  color: white;
}

.card-header h2 {
  margin: 0 0 0.5rem 0;
  font-size: 1.8rem;
  font-weight: 600;
}

.card-header p {
  margin: 0;
  font-size: 0.95rem;
  opacity: 0.9;
  font-weight: 300;
}

.login-form {
  padding: 1rem 0;
}

.input-wrapper {
  margin-bottom: 1.5rem;
}

.input-field {
  width: 100%;
  padding: 0.75rem;
  font-size: 1rem;
}

.login-button {
  width: 100%;
  padding: 0.75rem;
  font-size: 1.1rem;
  font-weight: 600;
  border-radius: 10px;
  margin-top: 1rem;
  transition: all 0.3s ease;
}

.login-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.demo-users {
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid rgba(0, 0, 0, 0.1);
  text-align: center;
}

.demo-title {
  font-size: 0.85rem;
  color: #666;
  margin-bottom: 0.5rem;
  font-weight: 600;
}

.demo-list {
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
}

.demo-user {
  font-size: 0.8rem;
  color: #667eea;
  font-family: 'Courier New', monospace;
  background: rgba(102, 126, 234, 0.1);
  padding: 0.3rem 0.6rem;
  border-radius: 5px;
  display: inline-block;
}

@media (max-width: 768px) {
  .card-header {
    padding: 1.5rem 1.5rem 1.5rem 1.5rem;
  }

  .avatar-circle {
    width: 60px;
    height: 60px;
  }

  .avatar-circle i {
    font-size: 1.5rem;
  }

  .card-header h2 {
    font-size: 1.5rem;
  }
}
</style>
