<script setup lang="ts">
import Card from 'primevue/card'
import Button from 'primevue/button'
import Chip from 'primevue/chip'
import type { PropType } from 'vue'
import type { User } from '@/types/user'

const props = defineProps({
  user: {
    type: Object as PropType<User>,
    required: true
  }
})

const emit = defineEmits<{
  (e: 'logout', user: User): void
}>()

const onLogout = () => emit('logout', props.user)

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  })
}
</script>

<template>
  <Card class="user-card">
    <template #header>
      <div class="profile-header">
        <div class="avatar-large">
          <i class="pi pi-user"></i>
        </div>
        <h2 class="user-name">{{ user.full_name }}</h2>
        <p class="user-username">@{{ user.username }}</p>
        <Chip 
          :label="user.role" 
          :icon="user.role === 'banker' ? 'pi pi-star' : 'pi pi-user'"
          :class="user.role === 'banker' ? 'role-chip-banker' : 'role-chip-depositor'"
        />
      </div>
    </template>

    <template #content>
      <div class="user-details">
        <div class="detail-row">
          <div class="detail-label">
            <i class="pi pi-envelope"></i>
            <span>Email</span>
          </div>
          <div class="detail-value">
            <a :href="`mailto:${user.email}`" class="email-link">
              {{ user.email }}
            </a>
          </div>
        </div>

        <div class="detail-row">
          <div class="detail-label">
            <i class="pi pi-shield"></i>
            <span>Email Status</span>
          </div>
          <div class="detail-value">
            <Chip 
              :label="user.is_email_verified ? 'Verified' : 'Not Verified'" 
              :icon="user.is_email_verified ? 'pi pi-check-circle' : 'pi pi-exclamation-triangle'"
              :class="user.is_email_verified ? 'status-verified' : 'status-unverified'"
            />
          </div>
        </div>

        <div class="detail-row">
          <div class="detail-label">
            <i class="pi pi-calendar"></i>
            <span>Member Since</span>
          </div>
          <div class="detail-value">
            {{ formatDate(user.created_at) }}
          </div>
        </div>

        <div class="detail-row">
          <div class="detail-label">
            <i class="pi pi-key"></i>
            <span>Password Changed</span>
          </div>
          <div class="detail-value">
            {{ user.password_changed_at === '0001-01-01T00:00:00Z' ? 'Never' : formatDate(user.password_changed_at) }}
          </div>
        </div>
      </div>
    </template>

    <template #footer>
      <div class="card-footer">
        <Button 
          label="Sign Out" 
          icon="pi pi-sign-out" 
          severity="danger"
          outlined
          @click="onLogout" 
          class="logout-button"
        />
      </div>
    </template>
  </Card>
</template>

<style scoped>
.user-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  overflow: hidden;
}

.profile-header {
  text-align: center;
  padding: 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  margin: -1rem -1rem 0 -1rem;
}

.avatar-large {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1rem auto;
  border: 4px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.avatar-large i {
  font-size: 3rem;
  color: white;
}

.user-name {
  margin: 0 0 0.25rem 0;
  font-size: 2rem;
  font-weight: 700;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.user-username {
  margin: 0 0 1rem 0;
  font-size: 1.1rem;
  opacity: 0.9;
  font-weight: 300;
}

.role-chip-banker,
.role-chip-depositor {
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.85rem;
  padding: 0.5rem 1rem;
}

.role-chip-banker {
  background: rgba(255, 215, 0, 0.9) !important;
  color: #000 !important;
}

.role-chip-depositor {
  background: rgba(255, 255, 255, 0.3) !important;
  color: white !important;
}

.user-details {
  padding: 1rem 0;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
  transition: background-color 0.3s ease;
}

.detail-row:hover {
  background-color: rgba(102, 126, 234, 0.05);
}

.detail-row:last-child {
  border-bottom: none;
}

.detail-label {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-weight: 600;
  color: #555;
}

.detail-label i {
  color: #667eea;
  font-size: 1.2rem;
}

.detail-value {
  color: #333;
  font-weight: 500;
}

.email-link {
  color: #667eea;
  text-decoration: none;
  transition: all 0.3s ease;
}

.email-link:hover {
  color: #764ba2;
  text-decoration: underline;
}

.status-verified {
  background: rgba(34, 197, 94, 0.2) !important;
  color: #16a34a !important;
}

.status-unverified {
  background: rgba(251, 146, 60, 0.2) !important;
  color: #ea580c !important;
}

.card-footer {
  padding: 1rem 0 0 0;
  display: flex;
  justify-content: center;
}

.logout-button {
  width: 100%;
  padding: 0.75rem;
  font-size: 1rem;
  font-weight: 600;
  border-radius: 10px;
  transition: all 0.3s ease;
}

.logout-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(239, 68, 68, 0.3);
}

@media (max-width: 768px) {
  .avatar-large {
    width: 80px;
    height: 80px;
  }

  .avatar-large i {
    font-size: 2.5rem;
  }

  .user-name {
    font-size: 1.5rem;
  }

  .detail-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }

  .detail-value {
    width: 100%;
  }
}
</style>
