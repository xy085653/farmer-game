using Demo.Data;

namespace Demo.Services;

public interface ITimeService
{
    GameTime CurrentTime { get; }
    SolarTerm CurrentTerm { get; }
    float TimeScale { get; set; }

    void AdvancePhase();
    void AdvanceToNextDay();
    SolarTermEffect GetCurrentTermEffect();
}
