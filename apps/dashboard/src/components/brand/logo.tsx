import { cn } from '@/lib/utils'

type LogoProps = {
  className?: string
  /** tone='dark' for light backgrounds, tone='light' for dark/branded backgrounds */
  tone?: 'dark' | 'light'
  /** Base size of the icon box (lg is the maximum at 150px) */
  size?: 'xs' | 'sm' | 'md' | 'lg'
  /** Multiplier for the SVG icon inside the box, default 1. Use to make the glyph larger. */
  scale?: number
}

const BASE_BOX = { xs: 32, sm: 48, md: 95, lg: 150 } as const
const BASE_SVG = { xs: 22, sm: 34, md: 68, lg: 108 } as const
const BASE_OFFSET = { xs: 5, sm: 15, md: 15, lg: 15 } as const
const WORD_RATIO = 72 / 95

function TaboorMark({
  box,
  svg,
  offset,
  tone,
}: {
  box: number
  svg: number
  offset: number
  tone: NonNullable<LogoProps['tone']>
}) {
  const front = tone === 'light' ? '#159F99' : '#0B4C56'

  return (
    <div
      className="relative shrink-0"
      style={{ width: box + offset, height: box + offset }}
      aria-hidden="true"
    >
      <div
        className="absolute right-0 bottom-0 rounded-[26%]"
        style={{ width: box, height: box, backgroundColor: '#F6A253' }}
      />
      <div
        className="absolute top-0 left-0 flex items-center justify-center rounded-[26%]"
        style={{ width: box, height: box, backgroundColor: front }}
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 1024 1024"
          width={svg}
          height={svg}
        >
          <path
            fill="#fff"
            fillRule="evenodd"
            d="
      M808 537 L802 525 L785 502 L766 487 L746 477 L726 471 L715 471
      L711 469 L683 471 L680 473 L667 475 L639 489 L615 511 L600 532
      L591 541 L584 552 L575 561 L554 590 L546 598 L540 608 L531 617
      L525 627 L514 638 L495 639 L487 643 L480 650 L475 661 L477 674
      L487 686 L495 690 L720 690 L748 682 L765 673 L781 660 L795 645
      L806 626 L816 591 L816 569 L814 566 L814 557 Z

      M757 552 L762 570 L761 598 L748 620 L742 626 L727 635 L712 639
      L590 639 L584 637 L661 539 L669 531 L680 525 L695 520 L709 520
      L724 524 L740 533 Z

      M540 323 L527 319 L288 319 L285 317 L276 317 L273 319 L257 319
      L254 321 L249 321 L231 329 L214 343 L205 353 L195 373 L195 379
      L191 389 L191 448 L199 468 L207 476 L215 480 L227 483 L281 484
      L281 512 L283 515 L281 520 L281 621 L287 644 L293 656 L311 676
      L340 689 L353 691 L374 690 L388 686 L405 677 L423 659 L432 642
      L436 624 L436 484 L481 483 L492 478 L500 468 L502 462 L502 449
      L496 437 L484 429 L450 427 L447 429 L425 429 L414 433 L405 439
      L391 453 L381 475 L381 620 L377 630 L370 636 L364 639 L355 639
      L343 631 L336 616 L336 465 L340 449 L349 429 L345 427 L246 427
      L244 422 L244 401 L249 388 L259 377 L271 372 L514 372 L522 375
      L532 383 L538 399 L539 572 L583 517 L592 503 L592 387 L590 384
      L590 377 L578 351 L562 335 Z
    "
          />
        </svg>
      </div>
    </div>
  )
}

export function Logo({
  className,
  tone = 'dark',
  size = 'md',
  scale = 1,
}: LogoProps) {
  const box = BASE_BOX[size]
  const svg = Math.min(Math.round(BASE_SVG[size] * scale), box - 4)
  const offset = BASE_OFFSET[size]
  const word = Math.round(box * WORD_RATIO)
  const wordColor = tone === 'light' ? '#FFFDF8' : '#0B4C56'

  return (
    <div className={cn('flex items-center gap-2', className)}>
      <TaboorMark box={box} svg={svg} offset={offset} tone={tone} />
      <span
        className="font-black tracking-[-0.035em] leading-none whitespace-nowrap"
        style={{ fontSize: word, color: wordColor }}
      >
        taboor<span style={{ color: '#F6A253' }}>.</span>
      </span>
    </div>
  )
}
