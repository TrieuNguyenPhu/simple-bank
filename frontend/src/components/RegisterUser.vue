<script setup lang="ts">
import InputGroup from 'primevue/inputgroup'
import InputGroupAddon from 'primevue/inputgroupaddon'
import FloatLabel from 'primevue/floatlabel'
import InputText from 'primevue/inputtext'
import Button from 'primevue/button'
import Card from 'primevue/card'
import { useToast } from 'primevue/usetoast'
import { ref } from 'vue'
import axios from 'axios'
import API_BASE_URL from '@/api'

const emit = defineEmits<{
  (e: 'registered'): void
}>()

const username = ref<string>('')
const password = ref<string>('')
const fullName = ref<string>('')
const email = ref<string>('')
const loading = ref<boolean>(false)
const toast = useToast()

const handleRegister = async () => {
  if (!username.value || !password.value || !fullName.value || !email.value) {
    toast.add({
      severity: 'warn',
      summary: 'Validation Error',
      detail: 'Please fill in all fields',
      life: 3000
    })
    return
  }

  loading.value = true
  
  try {
    await axios.post(
      `${API_BASE_URL}/v1/create_user`,
      {
        username: username.value,
        password: password.value,
        full_name: fullName.value,
        email: email.value
      },
      {
        headers: {
          'Content-Type': 'application/json'
        }
      }
    )

    toast.add({
      severity: 'success',
      summary: 'Registration Successful!',
      detail: 'You can now login with your credentials',
      life: 5000
    })
    
    emit('registered')
  } catch (error: any) {
    let errorMessage = 'An error occurred during registration'
    
    if (error.response) {
      if (error.response.status === 409) {
        errorMessage = 'Username or email already exists'
      } else if (error.response.data?.message) {
        errorMessage = error.response.data.message
      }
    }

    toast.add({
      severity: 'error',
      summary: 'Registration Failed',
      detail: errorMessage,
      life: 5000
    })
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <Card class="register-card">
    <template #header>
      <div class="card-header">
        <div class="avatar-circle">
          <i class="pi pi-user-plus"></i>
        </div>
        <h2>Create Account</h2>
        <p>Join Simple Bank today</p>
      </div>
    </template>

    <template #content>
      <div class="register-form">
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
              />
              <label for="username">Username</label>
            </FloatLabel>
          </InputGroup>
          <small class="field-hint">3-100 characters, letters, numbers, and underscore only</small>
        </div>

        <div class="input-wrapper">
          <InputGroup>
            <InputGroupAddon>
              <i class="pi pi-id-card"></i>
            </InputGroupAddon>
            <FloatLabel>
              <InputText 
                id="fullName" 
                v-model="fullName" 
                class="input-field"
              />
              <label for="fullName">Full Name</label>
            </FloatLabel>
          </InputGroup>
          <small class="field-hint">Letters and spaces only</small>
        </div>

        <div class="input-wrapper">
          <InputGroup>
            <InputGroupAddon>
              <i class="pi pi-envelope"></i>
            </InputGroupAddon>
            <FloatLabel>
              <InputText 
                id="email" 
                v-model="email" 
                type="email"
                class="input-field"
              />
              <label for="email">Email</label>
            </FloatLabel>
          </InputGroup>
          <small class="field-hint">Valid email address</small>
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
              />
              <label for="password">Password</label>
            </FloatLabel>
          </InputGroup>
          <small class="field-hint">Minimum 6 characters</small>
        </div>

        <Button 
          label="Create Account" 
          icon="pi pi-user-plus"
          :loading="loading"
          @click="handleRegister" 
          class="register-button"
          severity="success"
        />
      </div>
    </template>
  </Card>
</template>

<style scoped>
.register-card {
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

.register-form {
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

.field-hint {
  display: block;
  margin-top: 0.3rem;
  margin-left: 3rem;
  color: #666;
  font-size: 0.75rem;
}

.register-button {
  width: 100%;
  padding: 0.75rem;
  font-size: 1.1rem;
  font-weight: 600;
  border-radius: 10px;
  margin-top: 1rem;
  transition: all 0.3s ease;
}

.register-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
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
