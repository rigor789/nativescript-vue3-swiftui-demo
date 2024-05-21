<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "nativescript-vue";

const counter = ref(0);

let interval: any;

onMounted(() => {
  console.log("mounted");
  interval = setInterval(() => counter.value++, 100);
});

onUnmounted(() => {
  console.log("unmounted");
  clearInterval(interval);
});
</script>

<template>
  <StackLayout class="w-20 h-20 bg-gray-700 rounded-xl p-2">
    <Label class="text-lg text-red-500" text="Hello" />
    <Label class="text-lg text-blue-500" text="World" />
    <Label class="text-lg text-green-500" :text="counter" />
  </StackLayout>
</template>
