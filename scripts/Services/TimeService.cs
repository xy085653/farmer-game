using Godot;
using Demo.Data;
using Demo.Events;
using Demo.Core;

namespace Demo.Services;

public partial class TimeService : Node, ITimeService
{
    private const float RealSecondsPerGameMinute = 0.5f;

    private EventBus _eventBus;
    private GameTime _currentTime;
    private float _elapsedTime;
    private float _timeScale = 1.0f;

    public GameTime CurrentTime => _currentTime;
    public SolarTerm CurrentTerm => _currentTime.Term;

    public float TimeScale
    {
        get => _timeScale;
        set => _timeScale = Mathf.Max(0f, value);
    }

    public override void _Ready()
    {
        _eventBus = GetNode<EventBus>("/root/EventBus");

        _currentTime = new GameTime
        {
            Year = 1,
            Season = Season.Spring,
            Term = SolarTerm.LiChun,
            DayInTerm = 1,
            Phase = DayPhase.Morning,
            Minute = 360
        };

        _elapsedTime = 0f;
    }

    public override void _Process(double delta)
    {
        float dt = (float)delta;
        _elapsedTime += dt;

        float adjustedInterval = RealSecondsPerGameMinute / _timeScale;

        while (_elapsedTime >= adjustedInterval)
        {
            _elapsedTime -= adjustedInterval;
            TickMinute();
        }
    }

    private void TickMinute()
    {
        _currentTime.Minute++;

        if (_currentTime.Minute >= 1440)
        {
            EndDay();
            return;
        }

        DayPhase newPhase = GetPhaseForMinute(_currentTime.Minute);
        if (newPhase != _currentTime.Phase)
        {
            var oldPhase = _currentTime.Phase;
            _currentTime.Phase = newPhase;
            _eventBus.Publish(new DayPhaseEvent(oldPhase, newPhase));
        }
    }

    private static DayPhase GetPhaseForMinute(int minute)
    {
        if (minute < 600)
            return DayPhase.Morning;
        if (minute < 960)
            return DayPhase.Noon;
        if (minute < 1200)
            return DayPhase.Evening;
        return DayPhase.Night;
    }

    private void EndDay()
    {
        var oldTime = _currentTime;
        _eventBus.Publish(new DayEndedEvent(oldTime));

        _currentTime.Minute = 360;
        _currentTime.DayInTerm++;

        if (_currentTime.DayInTerm > 3)
        {
            AdvanceTerm();
        }

        _currentTime.Phase = DayPhase.Morning;
        _eventBus.Publish(new DayStartedEvent(_currentTime));
    }

    private void AdvanceTerm()
    {
        _currentTime.DayInTerm = 1;

        SolarTerm oldTerm = _currentTime.Term;
        int nextTermValue = (int)oldTerm + 1;

        if (nextTermValue > (int)SolarTerm.DaHan)
        {
            nextTermValue = (int)SolarTerm.LiChun;
            _currentTime.Year++;
        }

        SolarTerm newTerm = (SolarTerm)nextTermValue;
        _currentTime.Term = newTerm;

        Season oldSeason = SolarTermHelper.GetSeason(oldTerm);
        Season newSeason = SolarTermHelper.GetSeason(newTerm);

        SolarTermEffect effect = GetEffectForTerm(newTerm);
        _eventBus.Publish(new SolarTermEvent(oldTerm, newTerm, effect));

        if (oldSeason != newSeason)
        {
            _currentTime.Season = newSeason;
            _eventBus.Publish(new SeasonEvent(oldSeason, newSeason));
        }
    }

    public void AdvancePhase()
    {
        switch (_currentTime.Phase)
        {
            case DayPhase.Morning:
                _currentTime.Minute = 600;
                _currentTime.Phase = DayPhase.Noon;
                _eventBus.Publish(new DayPhaseEvent(DayPhase.Morning, DayPhase.Noon));
                break;

            case DayPhase.Noon:
                _currentTime.Minute = 960;
                _currentTime.Phase = DayPhase.Evening;
                _eventBus.Publish(new DayPhaseEvent(DayPhase.Noon, DayPhase.Evening));
                break;

            case DayPhase.Evening:
                _currentTime.Minute = 1200;
                _currentTime.Phase = DayPhase.Night;
                _eventBus.Publish(new DayPhaseEvent(DayPhase.Evening, DayPhase.Night));
                break;

            case DayPhase.Night:
                EndDay();
                break;
        }
    }

    public void AdvanceToNextDay()
    {
        EndDay();
    }

    public SolarTermEffect GetCurrentTermEffect()
    {
        return GetEffectForTerm(_currentTime.Term);
    }

    private static SolarTermEffect GetEffectForTerm(SolarTerm term)
    {
        return term switch
        {
            SolarTerm.LiChun => new SolarTermEffect
            {
                GrowthMultiplier = 1.2f,
                WaterCostMultiplier = 0.5f,
                PriceMultiplier = 1.0f,
                Description = "立春: 耕地不耗体力"
            },
            SolarTerm.GuYu => new SolarTermEffect
            {
                GrowthMultiplier = 1.3f,
                WaterCostMultiplier = 0.8f,
                PriceMultiplier = 1.0f,
                Description = "谷雨: 宜播种，作物生长加速"
            },
            SolarTerm.DaShu => new SolarTermEffect
            {
                GrowthMultiplier = 1.1f,
                WaterCostMultiplier = 0.5f,
                PriceMultiplier = 1.0f,
                Description = "大暑: 浇水需求减半"
            },
            SolarTerm.ShuangJiang => new SolarTermEffect
            {
                GrowthMultiplier = 0.5f,
                WaterCostMultiplier = 1.0f,
                PriceMultiplier = 1.0f,
                Description = "霜降: 作物可能冻死"
            },
            SolarTerm.DongZhi => new SolarTermEffect
            {
                GrowthMultiplier = 0.0f,
                WaterCostMultiplier = 1.0f,
                PriceMultiplier = 1.2f,
                Description = "冬至: 万物休养，物价上升"
            },
            _ => new SolarTermEffect
            {
                GrowthMultiplier = 1.0f,
                WaterCostMultiplier = 1.0f,
                PriceMultiplier = 1.0f,
                Description = ""
            }
        };
    }
}
