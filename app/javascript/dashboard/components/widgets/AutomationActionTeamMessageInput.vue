<script>
export default {
  props: {
    teams: { type: Array, required: true },
    modelValue: { type: Object, required: true },
  },
  emits: ['update:modelValue'],
  data() {
    return {
      selectedTeams: [],
      message: '',
    };
  },
  mounted() {
    const { team_ids: teamIds } = this.modelValue;
    this.selectedTeams = teamIds;
    this.message = this.modelValue.message;
  },
  methods: {
    updateValue() {
      this.$emit('update:modelValue', {
        team_ids: this.selectedTeams.map(team => team.id),
        message: this.message,
      });
    },
  },
};
</script>

<template>
  <div>
    <div class="multiselect-wrap--small flex flex-col gap-1 mt-1">
      <multiselect
        v-model="selectedTeams"
        track-by="id"
        label="name"
        :placeholder="$t('AUTOMATION.ACTION.TEAM_DROPDOWN_PLACEHOLDER')"
        multiple
        selected-label
        :select-label="$t('FORMS.MULTISELECT.ENTER_TO_SELECT')"
        deselect-label=""
        :max-height="160"
        :options="teams"
        :allow-empty="false"
        @update:model-value="updateValue"
      />
      <textarea
        v-model="message"
        rows="4"
        :placeholder="$t('AUTOMATION.ACTION.TEAM_MESSAGE_INPUT_PLACEHOLDER')"
        @input="updateValue"
      />
    </div>
  </div>
</template>

<style scoped>
.multiselect {
  margin: 0.25rem 0;
}
textarea {
  margin-bottom: 0;
}
</style>
