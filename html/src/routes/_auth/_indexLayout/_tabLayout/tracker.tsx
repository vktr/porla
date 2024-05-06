import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/_auth/_indexLayout/_tabLayout/tracker')({
  component: () => <div>Tracker tab content</div>
})