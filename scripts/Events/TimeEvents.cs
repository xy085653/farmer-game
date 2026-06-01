using Demo.Data;

namespace Demo.Events;

public record SolarTermEvent(SolarTerm OldTerm, SolarTerm NewTerm, SolarTermEffect Effect);

public record DayPhaseEvent(DayPhase OldPhase, DayPhase NewPhase);

public record SeasonEvent(Season OldSeason, Season NewSeason);

public record DayStartedEvent(GameTime Time);

public record DayEndedEvent(GameTime Time);
