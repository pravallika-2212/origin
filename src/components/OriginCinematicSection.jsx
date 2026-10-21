import React, { useEffect, useRef, useState, useMemo } from 'react';
import './OriginCinematicSection.css';

/**
 * ORIGIN Cinematic Scroll Experience & Royal Collection Section
 * Recreated with luxury aesthetics, performant rAF scroll tracking,
 * genuine editorial museum imagery, and responsive light-luxury transitions.
 */
export default function OriginCinematicSection({ onNavigate }) {
  const trackRef = useRef(null);
  const emberRef = useRef(null);
  const sweepRef = useRef(null);
  const ringsRef = useRef(null);
  const hlRingRef = useRef(null);
  const fadeRef = useRef(null);
  const collectionRef = useRef(null);

  const [reducedMotion, setReducedMotion] = useState(false);
  const [collectionVisible, setCollectionVisible] = useState(false);

  // Verified authentic editorial imagery
  const config = useMemo(() => ({
    scenes: [
      {
        id: 'crown',
        lines: ['Where Royalty', 'Begins'],
        sub: "Discover the artistry, symbolism and traditions behind the world's royal treasures.",
        image: '/assets/images/prod_austria_crown.jpg',
        fallback: 'https://images.metmuseum.org/CRDImages/ep/web-large/DP-14936-001.jpg',
        alt: 'Imperial Crown of Austria set with royal diamonds, rubies, sapphires and pearls',
        caption: 'Europe · Imperial Crown of Austria · Hofburg Vienna',
        reveal: 'iris',
        win: [0.0, 0.0, 0.20, 0.30]
      },
      {
        id: 'necklace',
        lines: ['The Art of', 'Adornment'],
        sub: 'Centuries of royal goldsmithing, uncut emeralds, and ceremonial kundan jewellery.',
        image: '/assets/images/prod_kundan_necklace.jpg',
        fallback: 'https://images.metmuseum.org/CRDImages/is/web-large/15.95.54.1.jpg',
        alt: 'Mughal Kundan and Colombian emerald ceremonial royal necklace',
        caption: 'India · Mughal Kundan & Emerald Necklace · The Met',
        reveal: 'rise',
        win: [0.20, 0.32, 0.46, 0.56]
      },
      {
        id: 'clothing',
        lines: ['Woven in', 'Heritage'],
        sub: 'Sacred ceremonial court silks, supplementary gold thread songket, and coronation robes.',
        image: '/assets/images/prod_korean_wonsam.jpg',
        fallback: 'https://images.metmuseum.org/CRDImages/as/web-large/206897.jpg',
        alt: 'Joseon Dynasty royal court embroidered ceremonial wonsam robe',
        caption: 'Korea · Joseon Royal Court Robe (Wonsam)',
        reveal: 'wipe',
        win: [0.46, 0.58, 0.70, 0.78]
      },
      {
        id: 'emblem',
        lines: ['Heritage,', 'Gathered in One Place'],
        sub: 'Curated from sovereign treasuries, royal dynasties, and celebrated ateliers across the globe.',
        image: '/assets/images/prod_chimu_gold.jpg',
        fallback: 'https://images.metmuseum.org/CRDImages/ao/web-large/DP-25936-001.jpg',
        alt: 'Pre-Columbian sovereign solid gold regalia sun plaque',
        caption: 'The Americas · Sovereign Sun Plaque Regalia',
        reveal: 'iris',
        center: true,
        win: [0.68, 0.78, 0.88, 0.95]
      }
    ],
    collection: {
      eyebrow: 'THE IMPERIAL REPERTORY',
      title: "Explore the World's Royal Heritage",
      sub: 'From exquisite jewellery and ceremonial fashion to palace décor and historic treasures, discover pieces inspired by royal traditions across the world.',
      cards: [
        {
          title: 'Crowns & Tiaras',
          desc: 'Handcrafted diadems, imperial crowns and ceremonial headpieces preserved in state archives.',
          image: '/assets/images/prod_austria_crown.jpg',
          badge: 'CERTIFIED REGALIA',
          route: '/shop?category=Imperial%20Jewels'
        },
        {
          title: 'Royal Jewellery',
          desc: 'Kundan chokers, Colombian emeralds and imperial gems set by master court goldsmiths.',
          image: '/assets/images/prod_kundan_necklace.jpg',
          badge: 'HEIRLOOM JEWELS',
          route: '/shop?category=Imperial%20Jewels'
        },
        {
          title: 'Royal Fashion',
          desc: 'Haute couture court robes, gold zari silks and traditional coronation ensembles.',
          image: '/assets/images/prod_korean_wonsam.jpg',
          badge: 'COURT COUTURE',
          route: '/shop?category=Royal%20Wardrobe'
        },
        {
          title: 'Palace Décor',
          desc: 'Water-gilded consoles, master khatam marquetry and sovereign throne room appointments.',
          image: '/assets/images/prod_versailles_console.jpg',
          badge: 'PALATIAL LIVING',
          route: '/shop?category=Palace%20Living'
        },
        {
          title: 'Antiques & Collectibles',
          desc: 'Museum-grade Jingdezhen cobalt porcelain, imperial seals and certified historical relics.',
          image: '/assets/images/prod_ming_vase.jpg',
          badge: 'MUSEUM ANTIQUITY',
          route: '/shop?category=Dining%20%26%20Tableware'
        },
        {
          title: 'Cultural Treasures',
          desc: 'Pre-Columbian gold regalia, Asante royal emblems and sacred global antiquities.',
          image: '/assets/images/prod_chimu_gold.jpg',
          badge: 'GLOBAL SOVEREIGNTY',
          route: '/shop?category=Treasures%20of%20the%20World'
        }
      ]
    }
  }), []);

  // Preload authentic museum imagery to avoid decoding frame drops
  useEffect(() => {
    config.scenes.forEach((s) => {
      if (s.image) {
        const img = new Image();
        img.src = s.image;
      }
    });
  }, [config]);

  // Check prefers-reduced-motion
  useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    setReducedMotion(mq.matches);
    const handler = (e) => setReducedMotion(e.matches);
    mq.addEventListener('change', handler);
    return () => mq.removeEventListener('change', handler);
  }, []);

  // Handle scroll-driven animation with cached DOM references
  useEffect(() => {
    if (reducedMotion) return;

    const clamp = (x, a = 0, b = 1) => Math.min(b, Math.max(a, x));
    const ease = (t) => t * t * (3 - 2 * t);
    const ramp = (p, a, b) => (a === b ? (p >= a ? 1 : 0) : ease(clamp((p - a) / (b - a))));

    // Cache scene DOM element references once to eliminate DOM query overhead during scrolling
    const cachedScenes = config.scenes.map((s) => {
      const el = document.getElementById(`scene-${s.id}`);
      if (!el) return null;
      return {
        id: s.id,
        win: s.win,
        reveal: s.reveal,
        el,
        lns: Array.from(el.querySelectorAll('.origin-cinematic-line > span')),
        sub: el.querySelector('.origin-cinematic-sub'),
        fig: el.querySelector('.origin-cinematic-figure'),
      };
    }).filter(Boolean);

    const staticCircles = ringsRef.current
      ? Array.from(ringsRef.current.querySelectorAll('.origin-ring-static'))
      : [];

    let ticking = false;

    const render = () => {
      ticking = false;
      const track = trackRef.current;
      if (!track) return;

      const r = track.getBoundingClientRect();
      const vh = window.innerHeight;
      if (r.bottom < -50 || r.top > vh + 50) return;

      const p = clamp(-r.top / (r.height - vh));
      const isMobile = window.innerWidth < 768;
      const par = isMobile ? 0 : 1;

      // Update cached scenes with zero DOM lookups
      for (let i = 0; i < cachedScenes.length; i++) {
        const s = cachedScenes[i];
        const [a0, a1, o0, o1] = s.win;
        const a = ramp(p, a0, a1);
        const o = ramp(p, o0, o1);
        const v = a - o;

        s.el.style.opacity = v > 0.001 ? '1' : '0';
        s.el.style.visibility = v > 0.001 ? 'visible' : 'hidden';

        // Headline lines
        const lns = s.lns;
        for (let j = 0; j < lns.length; j++) {
          const t = clamp(a * 1.25 - j * 0.2);
          lns[j].style.transform = `translateY(${((1 - ease(t)) * 110 - o * 110)}%)`;
        }

        // Subtitle
        if (s.sub) {
          s.sub.style.opacity = `${clamp(a * 1.4 - 0.4) * (1 - o)}`;
        }

        // Figure / Image
        if (s.fig) {
          s.fig.style.opacity = `${clamp(a * 1.6) * (1 - o)}`;
          s.fig.style.transform = `translateY(${(p - 0.5) * -36 * par}px) scale(${0.88 + 0.12 * a - 0.16 * o})`;
          if (a >= 0.999 && o <= 0.001) {
            s.fig.style.clipPath = 'none';
          } else if (s.reveal === 'iris') {
            s.fig.style.clipPath = `circle(${a * 75}% at 50% 50%)`;
          } else if (s.reveal === 'rise') {
            s.fig.style.clipPath = `inset(${(1 - a) * 100}% 0 0 0)`;
          } else if (s.reveal === 'wipe') {
            s.fig.style.clipPath = `inset(0 ${(1 - a) * 100}% 0 0)`;
          }
        }
      }

      // Lighting: warm ember
      if (emberRef.current) {
        const em = ramp(p, 0.0, 0.1) * (1 - ramp(p, 0.5, 0.7));
        emberRef.current.style.opacity = `${em}`;
        emberRef.current.style.transform = `translate(-50%, -50%) scale(${1 + ramp(p, 0.2, 0.55) * 0.4})`;
      }

      // Firelight sweep
      if (sweepRef.current) {
        const sw = ramp(p, 0.18, 0.5);
        sweepRef.current.style.opacity = `${Math.sin(Math.PI * sw) * 0.55}`;
        sweepRef.current.style.transform = `translate(-50%, -50%) scale(${0.05 + sw * 0.95})`;
      }

      // Ornamental Rings
      if (ringsRef.current) {
        const ra = ramp(p, 0.66, 0.82);
        const rf = 1 - ramp(p, 0.88, 0.95);
        ringsRef.current.style.opacity = `${ra * rf}`;
        ringsRef.current.style.transform = `scale(${0.9 + ra * 0.1 + (1 - rf) * -0.15})`;

        for (let k = 0; k < staticCircles.length; k++) {
          staticCircles[k].style.strokeDashoffset = `${1 - clamp(ra * 1.4 - k * 0.12)}`;
        }
      }

      // Rotating Accent Ring
      if (hlRingRef.current) {
        hlRingRef.current.style.strokeDashoffset = `${-(p * 1.2) % 1}`;
      }

      // Transition to royal ivory
      if (fadeRef.current) {
        fadeRef.current.style.opacity = `${ramp(p, 0.9, 1.0)}`;
      }
    };

    const onScroll = () => {
      if (!ticking) {
        ticking = true;
        requestAnimationFrame(render);
      }
    };

    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('resize', onScroll);
    render();

    return () => {
      window.removeEventListener('scroll', onScroll);
      window.removeEventListener('resize', onScroll);
    };
  }, [config, reducedMotion]);


  // Reveal collection cards via IntersectionObserver
  useEffect(() => {
    const el = collectionRef.current;
    if (!el) return;

    if (reducedMotion) {
      setCollectionVisible(true);
      return;
    }

    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          setCollectionVisible(true);
          observer.disconnect();
        }
      },
      { threshold: 0.15 }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, [reducedMotion]);

  const handleCardClick = (route) => {
    if (onNavigate) {
      onNavigate(route);
    } else {
      window.location.href = route;
    }
  };

  return (
    <section className="origin-cinematic-wrapper" aria-label="ORIGIN Chronicles & Imperial Collections">
      {/* 1. TALL SCROLL TRACK */}
      <div className={`origin-cinematic-track ${reducedMotion ? 'reduced-motion' : ''}`} ref={trackRef}>
        <div className="origin-cinematic-stage">
          {/* Deep Burgundy & Charcoal Atmosphere */}
          <div className="origin-cinematic-bg-burg" />
          <div className="origin-cinematic-ember" ref={emberRef} />
          <div className="origin-cinematic-sweep" ref={sweepRef} />

          {/* Sacred Ornamental Rings (SVG) */}
          <svg
            className="origin-cinematic-rings"
            ref={ringsRef}
            viewBox="-100 -100 200 200"
            preserveAspectRatio="xMidYMid slice"
            aria-hidden="true"
          >
            {[14, 26, 40, 56, 74].map((r) => (
              <circle
                key={r}
                className="origin-ring-static"
                r={r}
                pathLength="1"
                strokeDasharray="1"
                strokeDashoffset="1"
                style={{ opacity: 1 - r / 110 }}
              />
            ))}
            <circle
              ref={hlRingRef}
              id="origin-hl-ring"
              r="56"
              pathLength="1"
              strokeDasharray="0.07 0.93"
              style={{ strokeWidth: 2, stroke: '#d4622a', opacity: 0.8 }}
            />
          </svg>

          {/* Storytelling Scenes */}
          <div className="origin-cinematic-scenes-container">
            {config.scenes.map((scene) => (
              <div
                key={scene.id}
                id={`scene-${scene.id}`}
                className={`origin-cinematic-scene ${scene.center ? 'center' : ''}`}
              >
                <div className="origin-cinematic-txt">
                  <h2>
                    {scene.lines.map((line, i) => (
                      <span key={i} className="origin-cinematic-line">
                        <span>{line}</span>
                      </span>
                    ))}
                  </h2>
                  {scene.sub && <p className="origin-cinematic-sub">{scene.sub}</p>}
                </div>

                {scene.image && (
                  <figure className="origin-cinematic-figure">
                    <img
                      src={scene.image}
                      alt={scene.alt}
                      loading="lazy"
                      onError={(e) => {
                        if (scene.fallback && e.target.src !== scene.fallback) {
                          e.target.src = scene.fallback;
                        }
                      }}
                    />
                    <figcaption className="origin-cinematic-tag">{scene.caption}</figcaption>
                  </figure>
                )}
              </div>
            ))}
          </div>

          {/* Top Brand Pill Indicator */}
          <div className="origin-cinematic-ribbon">
            <span className="origin-cinematic-ribbon-dot" />
            <span>ORIGIN CHRONICLES · SCROLL TO DISCOVER</span>
          </div>

          {/* Final Ivory Hand-off Overlay */}
          <div className="origin-cinematic-fade-ivory" ref={fadeRef} />
        </div>
      </div>

      {/* 2. REFINED LIGHT LUXURY COLLECTION SECTION */}
      <div
        className={`origin-collection-section ${collectionVisible ? 'visible' : ''}`}
        ref={collectionRef}
      >
        <div className="origin-collection-container">
          <div className="origin-collection-crest">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" aria-hidden="true">
              <path d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z" />
            </svg>
          </div>

          <p className="origin-collection-eyebrow">{config.collection.eyebrow}</p>
          <h2 className="origin-collection-title">{config.collection.title}</h2>
          <p className="origin-collection-sub">{config.collection.sub}</p>

          <div className="origin-collection-grid">
            {config.collection.cards.map((card, idx) => (
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
                      e.target.style.display = 'none';
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
