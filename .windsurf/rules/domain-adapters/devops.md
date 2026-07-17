---
name: devops-adapter
domain: devops-infrastructure
applies_when: "Task changes live infrastructure, deploys, pipelines, IaC, monitoring, or runbooks. Script logic stays coding; live-state changes route here."
boundary: "Writing the IaC/script = coding adapter for the code, this adapter for the live-state change. Pure local build scripts = coding."
---

# DevOps / Infrastructure Adapter

## Minimum evidence set (binding — open before touching live state)
- The current live state (what's deployed now, what version, what config) — observed, not recalled.
- The blast radius of the change (what services/users are affected if it goes wrong).
- The rollback procedure (how to undo, and is it tested?).
- The change window / approval policy (is now an allowed time? who approves?).

## Evidence and primary sources
The system's actual observed state, a plan output, a re-read config, a metric, a log line — these
are primary sources. The IaC file is a claim about what should be running, not proof of what is.
The signature non-evidence: a green pipeline or an apply command that returned zero is not
evidence the system is healthy; only a post-change health check or metric is.

## Authority
Explicit user or owner instruction > the runbook or documented change policy > the platform's
current observed behavior > the IaC file's stated intent > your own judgment that "this should be
fine." The classic conflict: the repo says one thing, the running system does another; the running
system wins the diagnosis, but the fix targets whichever side actually caused the drift, named
explicitly.

## Verification by observation
- The change is confirmed applied to the target system (a plan/diff output, a post-change read of
  the live config or resource, a metric or log line proving it took effect), never inferred from
  "the command exited 0."
- Blast radius (which hosts, services, tenants, or regions) is named before an irreversible or
  shared-state action, and a rollback or dry-run path exists and was actually reviewed, not assumed.
- Health is checked after the change, not only before: the system still serves, error rates and
  latency did not regress, and no alert or threshold was quietly loosened to make the change look clean.
- Any outward-facing or irreversible step (deploy, apply to shared/prod infra, rotate a credential,
  edit a security group, restart a shared service) follows the authorization gate: no quoted user
  authorization, no action.

## Fraud table
| fraud | signal |
|------|--------|
| Big-bang deploy | a change pushed to all hosts or traffic with no canary, staged rollout, or stated blast radius |
| Silenced alerting | a threshold widened, a metric field swapped, or a check disabled instead of fixing the root cause it was catching |
| Untested rollback | a deploy or migration with no rollback path, or one claimed but never dry-run |
| Config drift denial | claiming the system matches the IaC or repo without checking the actual deployed state |
| Fabricated postmortem | an incident writeup with a root cause never reproduced or a timeline that does not match the logs |
| Secret in the clear | credentials, tokens, or keys committed to IaC, configs, or logs instead of a secrets manager |
| Unauthorized production touch | an apply, deploy, or restart against shared or production infra with no quoted user authorization |

## Done, by example
"The staging deploy is done" means: the plan or diff reviewed before apply, the change confirmed
live (not just "apply succeeded"), health checked post-change, a rollback path stated, and any
production or shared-infra step named as awaiting the user's authorization if it was not explicitly
given. Not: "the pipeline is green."

## Workflow
1. Observe current live state + blast radius + rollback + change window (binding).
2. Make the change; AUTH line required if outward-facing (per verbatim gates).
3. Re-query the live state; verify it matches intent.
4. State the rollback path; verify reachable.
5. fable-judge pass: re-query live state; verify health; check AUTH line; verify rollback.

## Sources
- live state: <query/endpoint> (accessed <date>)
- change policy: <doc path>
