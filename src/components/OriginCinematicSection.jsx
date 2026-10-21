import React, { useEffect, useRef, useState, useMemo, useCallback } from 'react';
import './OriginCinematicSection.css';

/**
 * ORIGIN 3D Rolling Cinematic Showcase & Imperial Collections
 * Inspired by the reference motion guide:
 * - 5 authentic royal heritage scenes in the exact sequence
 * - 3D rolling / rotating transitions with perspective and depth
 * - Autoplay with pause/play controls and animated progress fill bars
 * - Previous/Next controls, clickable scene indicators, keyboard shortcuts & gestures
 * - Seamless integration directly into the shopping collections below
 */
export default function OriginCinematicSection({ onNavigate }) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [direction, setDirection] = useState('fwd');
  const [isPlaying, setIsPlaying] = useState(true);
  const [reducedMotion, setReducedMotion] = useState(false);
  const [pointerTilt, setPointerTilt] = useState({ rx: 0, ry: 0 });

  const stageRef = useRef(null);
  const timerRef = useRef(null);
  const sweepRef = useRef(null);
  const collectionRef = useRef(null);
  const touchStartXRef = useRef(null);

  // The 5 Authenticated Scenes
  const scenes = useMemo(() => [
    {
      id: 'crown',
      name: 'Where Royalty Begins',
      theme: 'dark',
      lines: ['Where Royalty', 'Begins'],
      sub: "Discover the artistry, symbolism and traditions behind the world's royal treasures.",
      image: '/assets/images/prod_austria_crown.jpg',
      fallback: 'assets/images/prod_austria_crown.jpg',
      alt: 'Imperial Crown of Austria set with royal gemstones and pearl arches',
      caption: 'Europe · Imperial Crown of Austria · Hofburg Vienna'
    },
    {
      id: 'necklace',
      name: 'The Art of Adornment',
      theme: 'dark',
      lines: ['The Art of', 'Adornment'],
      sub: 'Centuries of royal goldsmithing, uncut emeralds, and ceremonial kundan jewellery.',
      image: '/assets/images/prod_kundan_necklace.jpg',
      fallback: 'assets/images/prod_kundan_necklace.jpg',
      alt: 'Mughal Kundan and Colombian emerald ceremonial royal necklace',
      caption: 'India · Mughal Kundan & Emerald Necklace · The Met',
      sweep: true
    },
    {
      id: 'clothing',
      name: 'Woven in Heritage',
      theme: 'dark',
      lines: ['Woven in', 'Heritage'],
      sub: 'Sacred ceremonial court silks, supplementary gold thread songket, and coronation robes.',
      image: '/assets/images/prod_korean_wonsam.jpg',
      fallback: 'assets/images/prod_korean_wonsam.jpg',
      alt: 'Joseon Dynasty royal court embroidered ceremonial wonsam robe',
      caption: 'Korea · Joseon Royal Court Robe (Wonsam)'
    },
    {
      id: 'emblem',
      name: 'Heritage, gathered in one place',
      theme: 'dark',
      center: true,
      rings: true,
      lines: ['Heritage,', 'gathered in one place'],
      sub: 'Curated from sovereign treasuries, royal dynasties, and celebrated ateliers across the globe.',
      image: '/assets/images/prod_chimu_gold.jpg',
      fallback: 'assets/images/prod_chimu_gold.jpg',
      alt: 'Pre-Columbian sovereign solid gold regalia sun plaque',
      caption: 'The Americas · Sovereign Sun Plaque Regalia'
    },
    {
      id: 'collection',
      name: "Explore the World's Royal Heritage",
      theme: 'light',
      lines: ['Explore the World’s', 'Royal Heritage'],
      sub: 'From crowns and tiaras to palace tableware, browse pieces from across the world.',
      image: '/assets/images/prod_versailles_console.jpg',
      fallback: 'assets/images/prod_versailles_console.jpg',
      alt: 'Versailles giltwood royal console with hand-carved acanthus leaves',
      caption: 'France · Versailles Giltwood Royal Console',
      chips: [
        { label: 'Crowns & Tiaras', cat: 'Imperial Jewels' },
        { label: 'Royal Jewellery', cat: 'Imperial Jewels' },
        { label: 'Royal Fashion', cat: 'Royal Wardrobe' },
        { label: 'Palace Décor', cat: 'Palace Living' },
        { label: 'Antiques & Collectibles', cat: 'Dining & Tableware' },
        { label: 'Cultural Treasures', cat: 'Treasures of the World' }
      ]
    }
  ], []);

  // Collection Cards directly below the stage
  const collectionCards = useMemo(() => [
    {
      title: 'Crowns & Tiaras',
      desc: 'Handcrafted diadems, imperial crowns and ceremonial headpieces preserved in state archives.',
      image: '/assets/images/prod_austria_crown.jpg',
      fallback: 'assets/images/prod_austria_crown.jpg',
      badge: 'CERTIFIED REGALIA',
      route: '/shop?category=Imperial%20Jewels'
    },
    {
      title: 'Royal Jewellery',
      desc: 'Kundan chokers, Colombian emeralds and imperial gems set by master court goldsmiths.',
      image: '/assets/images/prod_kundan_necklace.jpg',
      fallback: 'assets/images/prod_kundan_necklace.jpg',
      badge: 'HEIRLOOM JEWELS',
      route: '/shop?category=Imperial%20Jewels'
    },
    {
      title: 'Royal Fashion',
      desc: 'Haute couture court robes, gold zari silks and traditional coronation ensembles.',
      image: '/assets/images/prod_korean_wonsam.jpg',
      fallback: 'assets/images/prod_korean_wonsam.jpg',
      badge: 'COURT COUTURE',
      route: '/shop?category=Royal%20Wardrobe'
    },
    {
      title: 'Palace Décor',
      desc: 'Water-gilded consoles, master khatam marquetry and sovereign throne room appointments.',
      image: '/assets/images/prod_versailles_console.jpg',
      fallback: 'assets/images/prod_versailles_console.jpg',
      badge: 'PALATIAL LIVING',
      route: '/shop?category=Palace%20Living'
    },
    {
      title: 'Antiques & Collectibles',
      desc: 'Museum-grade Jingdezhen cobalt porcelain, imperial seals and certified historical relics.',
      image: '/assets/images/prod_ming_vase.jpg',
      fallback: 'assets/images/prod_ming_vase.jpg',
      badge: 'MUSEUM ANTIQUITY',
      route: '/shop?category=Dining%20%26%20Tableware'
    },
    {
      title: 'Cultural Treasures',
      desc: 'Pre-Columbian gold regalia, Asante royal emblems and sacred global antiquities.',
      image: '/assets/images/prod_chimu_gold.jpg',
      fallback: 'assets/images/prod_chimu_gold.jpg',
      badge: 'GLOBAL SOVEREIGNTY',
      route: '/shop?category=Treasures%20of%20the%20World'
    }
  ], []);

  // Preload images
  useEffect(() => {
    scenes.forEach((s) => {
      if (s.image) {
        const img = new Image();
        img.src = s.image;
      }
    });
  }, [scenes]);

  // Reduced motion preference
  useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    setReducedMotion(mq.matches);
    const handler = (e) => setReducedMotion(e.matches);
    mq.addEventListener('change', handler);
    return () => mq.removeEventListener('change', handler);
  }, []);

  // Transition handler
  const goTo = useCallback((targetIndex, dir) => {
    const N = scenes.length;
    const nextIdx = ((targetIndex % N) + N) % N;
    if (nextIdx === currentIndex) return;

    const fwd = dir !== undefined ? dir > 0 : nextIdx > currentIndex;
    setDirection(fwd ? 'fwd' : 'back');
    setCurrentIndex(nextIdx);
  }, [currentIndex, scenes.length]);

  // Autoplay timer (3.5 seconds)
  useEffect(() => {
    if (!isPlaying || reducedMotion) {
      if (timerRef.current) clearInterval(timerRef.current);
      return;
    }

    timerRef.current = setTimeout(() => {
      goTo(currentIndex + 1, 1);
    }, 3500);

    return () => {
      if (timerRef.current) clearTimeout(timerRef.current);
    };
  }, [currentIndex, isPlaying, reducedMotion, goTo]);

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e) => {
      if (e.key === 'ArrowRight') {
        goTo(currentIndex + 1, 1);
      } else if (e.key === 'ArrowLeft') {
        goTo(currentIndex - 1, -1);
      } else if (e.key === ' ' && e.target === document.body) {
        e.preventDefault();
        setIsPlaying((prev) => !prev);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [currentIndex, goTo]);

  // Touch swipe support
  const handleTouchStart = (e) => {
    touchStartXRef.current = e.touches[0].clientX;
  };

  const handleTouchEnd = (e) => {
    if (touchStartXRef.current === null) return;
    const diff = e.changedTouches[0].clientX - touchStartXRef.current;
    if (Math.abs(diff) > 50) {
      if (diff < 0) {
        goTo(currentIndex + 1, 1);
      } else {
        goTo(currentIndex - 1, -1);
      }
    }
    touchStartXRef.current = null;
  };

  // Fine-pointer 3D parallax tilt
  const handleMouseMove = (e) => {
    if (reducedMotion || !stageRef.current) return;
    const rect = stageRef.current.getBoundingClientRect();
    const px = (e.clientX - rect.left) / rect.width;
    const py = (e.clientY - rect.top) / rect.height;
    setPointerTilt({
      ry: (px - 0.5) * 12,
      rx: (0.5 - py) * 7
    });
  };

  const handleMouseLeave = () => {
    setPointerTilt({ rx: 0, ry: 0 });
  };

  const handleCardClick = (route) => {
    if (onNavigate) {
      onNavigate(route);
    } else {
      window.location.href = route;
    }
  };

  const scrollToCollection = () => {
    if (collectionRef.current) {
      collectionRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  };

  const activeScene = scenes[currentIndex];

  return (
    <section className="origin-rolling-wrapper" aria-label="ORIGIN Chronicles & Royal Showcase">
      {/* 1. THE 3D ROLLING STAGE */}
      <div
        className="origin-stage"
        ref={stageRef}
        data-theme={activeScene.theme}
        data-dir={direction}
        data-i={currentIndex}
        aria-roledescription="carousel"
        aria-label="ORIGIN royal heritage showcase"
        onTouchStart={handleTouchStart}
        onTouchEnd={handleTouchEnd}
        onMouseMove={handleMouseMove}
        onMouseLeave={handleMouseLeave}
        style={{
          '--rx': `${pointerTilt.rx.toFixed(2)}deg`,
          '--ry': `${pointerTilt.ry.toFixed(2)}deg`,
          '--dur': '3.5s'
        }}
      >
        <div className="origin-stage-base" />
        <div className="origin-stage-bg" />
        <div className="origin-stage-ember" />

        {/* Top Heritage Badge */}
        <div className="origin-stage-ribbon">
          <span className="origin-ribbon-dot" />
          <span>ORIGIN CHRONICLES · ROLLING SHOWCASE</span>
        </div>

        {/* The 5 Rolling Scenes */}
        <div className="origin-scenes-host">
          {scenes.map((scene, idx) => {
            const isActive = idx === currentIndex;
            const isLeaving = direction === 'fwd'
              ? idx === (currentIndex - 1 + scenes.length) % scenes.length
              : idx === (currentIndex + 1) % scenes.length;

            return (
              <article
                key={scene.id}
                className={`origin-scene ${scene.center ? 'center' : ''} ${isActive ? 'active' : ''} ${isLeaving ? 'leaving' : ''}`}
                aria-roledescription="slide"
                aria-label={`${idx + 1} of ${scenes.length}: ${scene.name}`}
                aria-hidden={!isActive}
              >
                {scene.sweep && <div className="origin-sweep" ref={sweepRef} />}

                {scene.rings && (
                  <svg
                    className="origin-rings"
                    viewBox="-100 -100 200 200"
                    preserveAspectRatio="xMidYMid slice"
                    aria-hidden="true"
                  >
                    {[14, 26, 40, 56, 74].map((r, k) => (
                      <circle
                        key={r}
                        r={r}
                        pathLength="1"
                        style={{ '--k': k, opacity: 1 - r / 110 }}
                      />
                    ))}
                    <circle className="origin-rings-hl" r="56" pathLength="1" />
                  </svg>
                )}

                <div className="origin-txt">
                  <h2>
                    {scene.lines.map((l, k) => (
                      <span key={k} className="origin-ln">
                        <span style={{ '--k': k }}>{l}</span>
                      </span>
                    ))}
                  </h2>

                  {scene.sub && <p className="origin-sub">{scene.sub}</p>}

                  {scene.chips && (
                    <>
                      <div className="origin-chips">
                        {scene.chips.map((chip) => (
                          <span
                            key={chip.label}
                            role="button"
                            tabIndex={0}
                            onClick={() => handleCardClick(`/shop?category=${encodeURIComponent(chip.cat)}`)}
                            onKeyDown={(e) => {
                              if (e.key === 'Enter') handleCardClick(`/shop?category=${encodeURIComponent(chip.cat)}`);
                            }}
                          >
                            {chip.label}
                          </span>
                        ))}
                      </div>
                      <div className="origin-collection-jump">
                        <button
                          type="button"
                          className="origin-btn-jump"
                          onClick={scrollToCollection}
                        >
                          BROWSE COLLECTION REPERTORY ↓
                        </button>
                      </div>
                    </>
                  )}
                </div>

                {scene.image && (
                  <figure className="origin-art">
                    <div className="origin-art-in" role="img" aria-label={scene.alt}>
                      <img
                        src={scene.image}
                        alt={scene.alt}
                        loading="eager"
                        onError={(e) => {
                          if (scene.fallback && e.target.src !== scene.fallback) {
                            e.target.src = scene.fallback;
                          }
                        }}
                      />
                    </div>
                    <figcaption className="origin-art-tag">{scene.caption}</figcaption>
                  </figure>
                )}
              </article>
            );
          })}
        </div>

        {/* Navigation & Autoplay Controls */}
        <nav className="origin-ctl" aria-label="Showcase controls">
          <button
            className="origin-ctl-btn"
            id="prev"
            aria-label="Previous scene"
            onClick={() => goTo(currentIndex - 1, -1)}
          >
            ‹
          </button>
          <button
            className="origin-ctl-btn"
            id="play"
            aria-label={isPlaying ? 'Pause' : 'Play'}
            onClick={() => setIsPlaying(!isPlaying)}
          >
            {isPlaying ? '❚❚' : '▶'}
          </button>
          <button
            className="origin-ctl-btn"
            id="next"
            aria-label="Next scene"
            onClick={() => goTo(currentIndex + 1, 1)}
          >
            ›
          </button>

          <div className="origin-dots" role="tablist" aria-label="Scene selection">
            {scenes.map((s, idx) => (
              <button
                key={s.id}
                className={`origin-dot ${idx === currentIndex ? 'on' : ''} ${!isPlaying ? 'paused' : ''}`}
                aria-label={`Go to ${s.name}`}
                aria-selected={idx === currentIndex}
                role="tab"
                onClick={() => goTo(idx)}
              >
                <span className="origin-dot-bar" />
              </button>
            ))}
          </div>

          <div className="origin-name" aria-live="polite">
            {activeScene.name}
          </div>
        </nav>
      </div>

      {/* 2. THE CLOSING COLLECTION SECTION */}
      <div className="origin-collection-section" ref={collectionRef}>
        <div className="origin-collection-container">
          <div className="origin-collection-crest">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" aria-hidden="true">
              <path d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z" />
            </svg>
          </div>

          <p className="origin-collection-eyebrow">THE IMPERIAL REPERTORY</p>
          <h2 className="origin-collection-title">Explore the World's Royal Heritage</h2>
          <p className="origin-collection-sub">
            From exquisite jewellery and ceremonial fashion to palace décor and historic treasures, discover pieces inspired by royal traditions across the world.
          </p>

          <div className="origin-collection-grid">
            {collectionCards.map((card, idx) => (
              <article
                key={card.title}
                className="origin-collection-card"
                style={{ '--i': idx }}
                onClick={() => handleCardClick(card.route)}
                tabIndex={0}
                role="button"
                onKeyDown={(e) => {
                  if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    handleCardClick(card.route);
                  }
                }}
              >
                <div className="origin-card-media">
                  <img
                    src={card.image}
                    alt={`${card.title} preview`}
                    loading="lazy"
                    onError={(e) => {
                      if (card.fallback && e.target.src !== card.fallback) {
                        e.target.src = card.fallback;
                      }
                    }}
                  />
                  <span className="origin-card-badge">{card.badge}</span>
                </div>
                <div className="origin-card-body">
                  <h3>{card.title}</h3>
                  <p>{card.desc}</p>
                  <span className="origin-card-link">
                    DISCOVER COLLECTION <span aria-hidden="true">→</span>
                  </span>
                </div>
              </article>
            ))}
          </div>

          <div className="origin-collection-action">
            <button
              className="origin-btn-all"
              onClick={() => handleCardClick('/shop')}
            >
              EXPLORE ALL ROYAL COLLECTIONS <span aria-hidden="true">→</span>
            </button>
          </div>
        </div>
      </div>
    </section>
  );
}
