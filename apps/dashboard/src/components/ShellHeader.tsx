import { usePageHeaderSlot } from './layout/PageHeaderSlot'
import { SidebarTrigger } from './ui/sidebar'

export default function ShellHeader() {
  const { register } = usePageHeaderSlot()

  return (
    <header className="sticky top-0 z-10 flex h-14 shrink-0 items-center gap-2 border-b border-foreground/10 bg-background/95 px-4 backdrop-blur">
      <SidebarTrigger />

      <div className="min-w-0 flex-1" ref={register} />

      {/* ThemeToggle slot reserved */}
    </header>
  )
}
