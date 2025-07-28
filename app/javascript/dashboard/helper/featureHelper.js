const FEATURE_HELP_URLS = {
  agent_bots: 'https://chatmy.ae/hc/agent-bots',
  agents: 'https://chatmy.ae/hc/agents',
  audit_logs: 'https://chatmy.ae/hc/audit-logs',
  campaigns: 'https://chatmy.ae/hc/campaigns',
  canned_responses: 'https://chatmy.ae/hc/canned',
  channel_email: 'https://chatmy.ae/hc/email',
  channel_facebook: 'https://chatmy.ae/hc/fb',
  custom_attributes: 'https://chatmy.ae/hc/custom-attributes',
  dashboard_apps: 'https://chatmy.ae/hc/dashboard-apps',
  help_center: 'https://chatmy.ae/hc/help-center',
  inboxes: 'https://chatmy.ae/hc/inboxes',
  integrations: 'https://chatmy.ae/hc/integrations',
  labels: 'https://chatmy.ae/hc/labels',
  macros: 'https://chatmy.ae/hc/macros',
  message_reply_to: 'https://chatmy.ae/hc/reply-to',
  reports: 'https://chatmy.ae/hc/reports',
  sla: 'https://chatmy.ae/hc/sla',
  team_management: 'https://chatmy.ae/hc/teams',
  webhook: 'https://chatmy.ae/hc/webhooks',
  billing: 'https://chatmy.ae/pricing',
};

export function getHelpUrlForFeature(featureName) {
  return FEATURE_HELP_URLS[featureName];
}
