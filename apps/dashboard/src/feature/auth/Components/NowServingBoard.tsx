import { Ticket } from 'lucide-react'

const NEXT_TICKETS = [
  { number: 'A-043', label: 'Station 1', eta: '~4 min' },
  { number: 'A-044', label: 'Station 3', eta: '~7 min' },
]

export default function NowServingBoard() {
  return (
    <div className="w-full max-w-sm rounded-3xl border border-white/10 bg-white/5 p-5 shadow-2xl shadow-black/20 backdrop-blur-sm">
      <div className="flex items-center justify-between">
        <span className="flex items-center gap-2 text-xs font-medium tracking-wide text-white/70 uppercase">
          <Ticket className="size-4" />
          Now serving
        </span>
        <span className="relative flex size-2.5">
          <span className="absolute inline-flex h-full w-full rounded-full bg-amber opacity-75 motion-safe:animate-ping" />
          <span className="relative inline-flex size-2.5 rounded-full bg-amber" />
        </span>
      </div>

      <div className="mt-4 flex items-end gap-4">
        <div className="rounded-2xl bg-amber px-5 py-2.5">
          <p className="text-4xl font-black tracking-tight text-ink">A-042</p>
        </div>
        <div className="pb-1">
          <p className="text-sm font-semibold text-white">Station 2</p>
          <p className="text-xs text-white/60">Serving now</p>
        </div>
      </div>

      <div className="mt-5 space-y-3 border-t border-white/10 pt-4">
        {NEXT_TICKETS.map((ticket) => (
          <div
            key={ticket.number}
            className="flex items-center justify-between"
          >
            <span className="text-sm font-semibold text-white/90">
              {ticket.number}
            </span>
            <span className="text-xs text-white/50">
              {ticket.label} · {ticket.eta}
            </span>
          </div>
        ))}
      </div>
    </div>
  )
}
