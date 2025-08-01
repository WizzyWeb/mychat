<script>
import NextButton from 'dashboard/components-next/button/Button.vue';

export default {
  name: 'FilterInput',
  components: {
    NextButton,
  },
  props: {
    modelValue: {
      type: Object,
      default: () => {},
    },
    filterAttributes: {
      type: Array,
      default: () => [],
    },
    inputType: {
      type: String,
      default: 'plain_text',
    },
    operators: {
      type: Array,
      default: () => [],
    },
    dropdownValues: {
      type: Array,
      default: () => [],
    },
    showQueryOperator: {
      type: Boolean,
      default: false,
    },
    showUserInput: {
      type: Boolean,
      default: true,
    },
    groupedFilters: {
      type: Boolean,
      default: false,
    },
    filterGroups: {
      type: Array,
      default: () => [],
    },
    customAttributeType: {
      type: String,
      default: '',
    },
    errorMessage: {
      type: String,
      default: '',
    },
  },
  emits: ['update:modelValue', 'removeFilter', 'resetFilter'],
  computed: {
    attributeKey: {
      get() {
        if (!this.modelValue) return null;
        return this.modelValue.attribute_key;
      },
      set(value) {
        const payload = this.modelValue || {};
        this.$emit('update:modelValue', { ...payload, attribute_key: value });
      },
    },
    filterOperator: {
      get() {
        if (!this.modelValue) return null;
        return this.modelValue.filter_operator;
      },
      set(value) {
        const payload = this.modelValue || {};
        this.$emit('update:modelValue', { ...payload, filter_operator: value });
      },
    },
    values: {
      get() {
        if (!this.modelValue) return null;
        return this.modelValue.values;
      },
      set(value) {
        const payload = this.modelValue || {};
        this.$emit('update:modelValue', { ...payload, values: value });
      },
    },
    query_operator: {
      get() {
        if (!this.modelValue) return null;
        return this.modelValue.query_operator;
      },
      set(value) {
        const payload = this.modelValue || {};
        this.$emit('update:modelValue', { ...payload, query_operator: value });
      },
    },
    custom_attribute_type: {
      get() {
        if (!this.customAttributeType) return '';
        return this.customAttributeType;
      },
      set() {
        const payload = this.modelValue || {};
        this.$emit('update:modelValue', {
          ...payload,
          custom_attribute_type: this.customAttributeType,
        });
      },
    },
  },
  watch: {
    customAttributeType: {
      handler(value) {
        if (
          value === 'conversation_attribute' ||
          value === 'contact_attribute'
        ) {
          // eslint-disable-next-line vue/no-mutating-props
          this.modelValue.custom_attribute_type = this.customAttributeType;
          // eslint-disable-next-line vue/no-mutating-props
        } else this.modelValue.custom_attribute_type = '';
      },
      immediate: true,
    },
  },
  methods: {
    removeFilter() {
      this.$emit('removeFilter');
    },
    resetFilter() {
      this.$emit('resetFilter');
    },
    getInputErrorClass(errorMessage) {
      return errorMessage
        ? 'bg-n-ruby-8/20 border-n-ruby-5 dark:border-n-ruby-5'
        : 'bg-n-background border-n-weak dark:border-n-weak';
    },
  },
};
</script>

<!-- eslint-disable vue/no-mutating-props -->
<template>
  <div>
    <div
      class="p-2 border border-solid rounded-lg"
      :class="getInputErrorClass(errorMessage)"
    >
      <div class="flex gap-1">
        <select
          v-if="groupedFilters"
          v-model="attributeKey"
          class="max-w-[30%] mb-0 mr-1"
          @change="resetFilter()"
        >
          <optgroup
            v-for="(group, i) in filterGroups"
            :key="i"
            :label="group.name"
          >
            <option
              v-for="attribute in group.attributes"
              :key="attribute.key"
              :value="attribute.key"
              :selected="true"
            >
              {{ attribute.name }}
            </option>
          </optgroup>
        </select>
        <select
          v-else
          v-model="attributeKey"
          class="max-w-[30%] mb-0 mr-1"
          @change="resetFilter()"
        >
          <option
            v-for="attribute in filterAttributes"
            :key="attribute.key"
            :value="attribute.key"
            :disabled="attribute.disabled"
          >
            {{ attribute.name }}
          </option>
        </select>

        <select v-model="filterOperator" class="max-w-[20%] mb-0 mr-1">
          <option
            v-for="(operator, o) in operators"
            :key="o"
            :value="operator.value"
          >
            {{ $t(`FILTER.OPERATOR_LABELS.${operator.value}`) }}
          </option>
        </select>

        <div v-if="showUserInput" class="flex-grow mr-1 filter__answer--wrap">
          <div
            v-if="inputType === 'multi_select'"
            class="multiselect-wrap--small"
          >
            <multiselect
              v-model="values"
              track-by="id"
              label="name"
              :placeholder="$t('FORMS.MULTISELECT.SELECT')"
              multiple
              selected-label
              :select-label="$t('FORMS.MULTISELECT.ENTER_TO_SELECT')"
              deselect-label=""
              :max-height="160"
              :options="dropdownValues"
              :allow-empty="false"
            >
              <template #noOptions>
                {{ $t('FORMS.MULTISELECT.NO_OPTIONS') }}
              </template>
            </multiselect>
          </div>
          <div
            v-else-if="inputType === 'search_select'"
            class="multiselect-wrap--small"
          >
            <multiselect
              v-model="values"
              track-by="id"
              label="name"
              :placeholder="$t('FORMS.MULTISELECT.SELECT')"
              selected-label
              :select-label="$t('FORMS.MULTISELECT.ENTER_TO_SELECT')"
              deselect-label=""
              :max-height="160"
              :options="dropdownValues"
              :allow-empty="false"
              :option-height="104"
            >
              <template #noOptions>
                {{ $t('FORMS.MULTISELECT.NO_OPTIONS') }}
              </template>
            </multiselect>
          </div>
          <div v-else-if="inputType === 'date'" class="multiselect-wrap--small">
            <input
              v-model="values"
              type="date"
              :editable="false"
              class="!mb-0 datepicker"
            />
          </div>
          <input
            v-else
            v-model="values"
            type="text"
            class="!mb-0"
            :placeholder="$t('FILTER.INPUT_PLACEHOLDER')"
          />
        </div>
        <NextButton
          icon="i-lucide-x"
          slate
          ghost
          class="flex-shrink-0"
          @click="removeFilter"
        />
      </div>
      <p v-if="errorMessage" class="filter-error">
        {{ errorMessage }}
      </p>
    </div>

    <div
      v-if="showQueryOperator"
      class="flex items-center justify-center relative my-2.5 mx-0"
    >
      <hr class="absolute w-full border-b border-solid border-n-weak" />
      <select
        v-model="query_operator"
        class="relative w-auto mb-0 bg-n-background text-n-slate-12 border-n-weak"
      >
        <option value="and">
          {{ $t('FILTER.QUERY_DROPDOWN_LABELS.AND') }}
        </option>
        <option value="or">
          {{ $t('FILTER.QUERY_DROPDOWN_LABELS.OR') }}
        </option>
      </select>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.filter__answer--wrap {
  input {
    @apply bg-n-background mb-0 text-n-slate-12 border-n-weak;
  }
}

.filter-error {
  @apply text-n-ruby-9 dark:text-n-ruby-9 block my-1 mx-0;
}

.multiselect {
  @apply mb-0;
}
</style>
