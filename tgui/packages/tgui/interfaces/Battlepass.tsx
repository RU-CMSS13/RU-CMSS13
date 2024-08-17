import { BooleanLike, classes } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Dimmer, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

interface BattlepassReward {
  name: string;
  icon_state: string;
  tier: number;
  lifeform_type: string;
}

interface BattlepassChallenge {
  name: string;
  desc: string;
  completed: BooleanLike;
  category: string;
  completion_xp: number;
  completion_percent: number;
  completion_numerator: number;
  completion_denominator: number;
}

interface BattlepassData {
  season: string;
  xp: number;
  tier: number;
  max_tier: number;
  xp_tierup: number;
  rewards: BattlepassReward[];
  premium_rewards: BattlepassReward[];
  daily_challenges: BattlepassChallenge[];
}

export const Battlepass = (props) => {
  return (
    <Window width={1850} height={610} theme="usmc" title="Battlepass">
      <Window.Content>
        <BattlepassContent />
      </Window.Content>
    </Window>
  );
};

const BattlepassContent = (props) => {
  const { act, data } = useBackend<BattlepassData>();
  const rewards = data.rewards;
  const premium_rewards = data.premium_rewards;
  const [infoView, setInfoView] = useState(0);

  const rewardMap = new Map(rewards.map((reward) => [reward.tier, reward]));
  const premiumRewardMap = new Map(
    premium_rewards.map((reward) => [reward.tier, reward]),
  );

  return (
    <>
      {infoView && (
        <Dimmer>
          <Box
            style={{
              width: '800px',
              height: '460px',
              display: 'flex',
              backgroundColor: '#0c0e1e',
              fontFamily: 'Verdana, Geneva, sans-serif',
              textAlign: 'center',
              justifyContent: 'center',
              alignItems: 'center',
              fontSize: '18px',
              padding: '10px',
            }}
          >
            <Section
              title="Battlepass"
              style={{
                width: '100%',
                height: '100%',
              }}
            >
              The battlepass system is a way of rewarding players with in-game
              rewards for playing well.
              <Box style={{ height: '10px' }} />
              <Button
                fontSize="16px"
                icon="xmark"
                onClick={() => setInfoView(0)}
              >
                Exit
              </Button>
            </Section>
          </Box>
        </Dimmer>
      )}
      <Box
        style={{
          display: 'flex',
          overflow: 'auto',
        }}
      >
        <BattlepassInfoContainer />
        <Box
          style={{
            overflowX: 'auto',
            display: 'flex',
            flexWrap: 'wrap',
            position: 'relative',
            maxWidth: '1500px',
            minWidth: '1500px',
          }}
        >
          {Array.from({ length: data.max_tier }, (_, tier) => tier + 1).map(
            (tier) => {
              const reward = rewardMap.get(tier);
              const premiumReward = premiumRewardMap.get(tier);
              return (
                <BattlepassRegularEntry
                  key={tier}
                  reward={reward}
                  premiumReward={premiumReward}
                />
              );
            },
          )}
        </Box>
      </Box>
    </>
  );
};

const BattlepassInfoContainer = (props) => {
  const { act, data } = useBackend<BattlepassData>();
  const [infoView, setInfoView] = useState(0);
  return (
    <Box
      style={{
        paddingRight: '20px',
        borderRight: 'solid',
      }}
    >
      <Section title={data.season}>
        <Button
          fontSize="12px"
          icon="circle-info"
          onClick={() => setInfoView(1)}
        >
          Information
        </Button>
        <Box style={{ height: '10px' }} />
        <Box style={{ fontWeight: 'bold', fontSize: '16px' }}>
          Tier: {data.tier} / {data.max_tier}
          <Box style={{ height: '10px' }} />
          XP: {data.xp} / 10
        </Box>
        {data.daily_challenges.map((challenge) => (
          <BattlepassChallengeUI challenge={challenge} key={challenge.name} />
        ))}
      </Section>
    </Box>
  );
};

const BattlepassChallengeUI = (props) => {
  const challenge: BattlepassChallenge = props.challenge;
  return (
    <Section title={`${challenge.category} - ${challenge.name}`}>
      {challenge.desc}
      <Box style={{ paddingBottom: '4px' }} />
      <ProgressBar
        minValue={0}
        maxValue={1}
        value={challenge.completion_percent}
        ranges={{
          bad: [0, 0.4],
          average: [0.4, 0.7],
          good: [0.7, 1],
        }}
      >
        Completion: {challenge.completion_numerator} /{' '}
        {challenge.completion_denominator}
      </ProgressBar>
      Reward: {challenge.completion_xp} XP
    </Section>
  );
};

const BattlepassRegularEntry = (props) => {
  const { act, data } = useBackend<BattlepassData>();
  const reward: BattlepassReward | undefined = props.reward;
  const premiumReward: BattlepassReward | undefined = props.premiumReward;
  return (
    <Box
      style={{
        borderStyle: 'none',
        borderWidth: '2px',
        borderColor: 'black',
        marginRight: '10px',
        width: '135px',
      }}
    >
      {reward ? (
        <>
          <Box
            style={{
              backgroundColor:
                data.tier >= reward.tier
                  ? 'rgba(0, 255, 0, 0.4)'
                  : 'rgba(255, 0, 0, 0.4)',
              width: '100%',
              paddingTop: '3px',
              paddingBottom: '3px',
              textAlign: 'center',
            }}
          >
            {reward.name}
          </Box>
          <Box
            style={{
              backgroundImage: 'linear-gradient(black, transparent)',
            }}
          >
            <Box
              style={{
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
              }}
            >
              <Box
                style={{ display: 'inline', fontWeight: 'bold' }}
                className={classes(['battlepass96x96', `${reward.icon_state}`])}
              />
            </Box>
            <Box
              style={{
                textAlign: 'center',
              }}
            >
              ({reward.lifeform_type})
            </Box>
          </Box>
          <Box
            style={{
              backgroundImage:
                data.tier >= reward.tier
                  ? 'linear-gradient(rgba(0, 255, 0, 0.4), rgba(212, 68, 23, 0.4))'
                  : 'linear-gradient(rgba(255, 0, 0, 0.4), rgba(212, 68, 23, 0.4))',
              width: '100%',
              paddingTop: '3px',
              paddingBottom: '3px',
              textAlign: 'center',
            }}
          >
            {reward.tier}
          </Box>
        </>
      ) : (
        <Box
          style={{
            height: '135px',
            backgroundColor: 'rgba(255, 255, 255, 0.1)',
          }}
        />
      )}

      {premiumReward && (
        <Box
          style={{
            opacity: '0.5',
          }}
        >
          <Box
            style={{
              backgroundImage: 'linear-gradient(black, transparent)',
            }}
          >
            <Box
              style={{
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
              }}
            >
              <Box
                style={{ display: 'inline', fontWeight: 'bold' }}
                className={classes([
                  'battlepass96x96',
                  `${premiumReward.icon_state}`,
                ])}
              />
            </Box>
            <Box
              style={{
                textAlign: 'center',
              }}
            >
              ({premiumReward.lifeform_type})
            </Box>
          </Box>
          <Box
            style={{
              backgroundColor: 'rgba(212, 68, 23, 0.4)',
              width: '100%',
              paddingTop: '3px',
              paddingBottom: '3px',
              textAlign: 'center',
            }}
          >
            {premiumReward.name}
          </Box>
        </Box>
      )}
    </Box>
  );
};
