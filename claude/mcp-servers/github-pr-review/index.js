import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { execFileSync } from 'child_process';
import { z } from 'zod';

const server = new McpServer({
  name: 'github-pr-review',
  version: '1.0.0',
});

server.registerTool(
  'get_pr_info',
  {
    description:
      'Get PR metadata including node ID, number, branch names, and URL',
  },
  async () => {
    const output = execFileSync(
      'gh',
      ['pr', 'view', '--json', 'id,number,title,baseRefName,headRefName,url'],
      { encoding: 'utf8' }
    );

    return {
      content: [{ type: 'text', text: output }],
    };
  }
);

server.registerTool(
  'get_pr_files',
  {
    description: 'Get all files changed in a PR with their viewed state',
    inputSchema: {
      owner: z.string().describe('Repository owner'),
      repo: z.string().describe('Repository name'),
      pr_number: z.number().describe('Pull request number'),
    },
  },
  async ({ owner, repo, pr_number }) => {
    const query = `{
      repository(owner: "${owner}", name: "${repo}") {
        pullRequest(number: ${pr_number}) {
          files(first: 100) {
            nodes {
              path
              viewerViewedState
              additions
              deletions
            }
          }
        }
      }
    }`;

    const output = execFileSync(
      'gh',
      ['api', 'graphql', '-f', `query=${query}`],
      {
        encoding: 'utf8',
      }
    );

    const files = JSON.parse(output).data.repository.pullRequest.files.nodes;

    return {
      content: [{ type: 'text', text: JSON.stringify(files, null, 2) }],
    };
  }
);

server.registerTool(
  'mark_files_as_viewed',
  {
    description: 'Mark one or more PR files as viewed in GitHub',
    inputSchema: {
      pr_node_id: z.string().describe('The PR node ID (from get_pr_info)'),
      paths: z.array(z.string()).describe('File paths to mark as viewed'),
    },
  },
  async ({ pr_node_id, paths }) => {
    const aliases = paths
      .map(
        (path, i) =>
          `m${i}: markFileAsViewed(input: { pullRequestId: "${pr_node_id}", path: "${path}" }) { pullRequest { id } }`
      )
      .join('\n    ');

    const query = `mutation {\n    ${aliases}\n  }`;

    execFileSync('gh', ['api', 'graphql', '-f', `query=${query}`], {
      encoding: 'utf8',
    });

    return {
      content: [
        {
          type: 'text',
          text: `Marked ${paths.length} file(s) as viewed: ${paths.join(', ')}`,
        },
      ],
    };
  }
);

server.registerTool(
  'get_pending_review',
  {
    description: "Get the current user's pending PR review, if one exists",
    inputSchema: {
      owner: z.string().describe('Repository owner'),
      repo: z.string().describe('Repository name'),
      pr_number: z.number().describe('Pull request number'),
    },
  },
  async ({ owner, repo, pr_number }) => {
    const currentUser = JSON.parse(
      execFileSync('gh', ['api', 'user'], { encoding: 'utf8' })
    ).login;

    const reviews = JSON.parse(
      execFileSync('gh', ['api', `repos/${owner}/${repo}/pulls/${pr_number}/reviews`], { encoding: 'utf8' })
    );

    const pendingReview = reviews.find(r => r.state === 'PENDING' && r.user.login === currentUser);

    return {
      content: [{
        type: 'text',
        text: pendingReview ? JSON.stringify(pendingReview, null, 2) : 'No pending review found',
      }],
    };
  }
);

server.registerTool(
  'create_review',
  {
    description: 'Start a new pending PR review, optionally with initial comments',
    inputSchema: {
      owner: z.string().describe('Repository owner'),
      repo: z.string().describe('Repository name'),
      pr_number: z.number().describe('Pull request number'),
      comments: z.array(z.object({
        path: z.string().describe('Relative file path'),
        line: z.number().describe('Last line of the comment'),
        start_line: z.number().optional().describe('First line for multi-line comment'),
        side: z.enum(['LEFT', 'RIGHT']).default('RIGHT').describe('Which side of the diff'),
        body: z.string().describe('Comment text'),
      })).optional().describe('Initial comments to include with the review'),
    },
  },
  async ({ owner, repo, pr_number, comments }) => {
    const commits = JSON.parse(
      execFileSync('gh', ['pr', 'view', String(pr_number), '--repo', `${owner}/${repo}`, '--json', 'commits'], { encoding: 'utf8' })
    ).commits;
    const commit_id = commits[commits.length - 1].oid;

    const payload = { commit_id, body: '', ...(comments?.length ? { comments } : {}) };

    const output = execFileSync(
      'gh',
      ['api', `repos/${owner}/${repo}/pulls/${pr_number}/reviews`, '--method', 'POST', '--input', '-'],
      { input: JSON.stringify(payload), encoding: 'utf8' }
    );

    return { content: [{ type: 'text', text: output }] };
  }
);

server.registerTool(
  'add_review_comment',
  {
    description: 'Add a comment to a PR diff. Requires pull_request_review_id (node_id, format PRR_...) from get_pending_review or create_review.',
    inputSchema: {
      pull_request_review_id: z.string().describe('Node ID of the pending review (PRR_...) from get_pending_review or create_review'),
      path: z.string().describe('Relative file path'),
      line: z.number().describe('Line number to comment on (last line for multi-line)'),
      start_line: z.number().optional().describe('First line for a multi-line comment'),
      side: z.enum(['LEFT', 'RIGHT']).default('RIGHT').describe('Which side of the diff'),
      body: z.string().describe('Comment text'),
    },
  },
  async ({ pull_request_review_id, path, line, start_line, side, body }) => {
    const input = {
      pullRequestReviewId: pull_request_review_id,
      path,
      line,
      side,
      body,
      ...(start_line !== undefined ? { startLine: start_line, startSide: side } : {}),
    };

    const payload = {
      query: `mutation AddThread($input: AddPullRequestReviewThreadInput!) {
        addPullRequestReviewThread(input: $input) {
          thread { id }
        }
      }`,
      variables: { input },
    };

    const output = execFileSync(
      'gh',
      ['api', 'graphql', '--input', '-'],
      { input: JSON.stringify(payload), encoding: 'utf8' }
    );

    return { content: [{ type: 'text', text: output }] };
  }
);

server.registerTool(
  'submit_review_event',
  {
    description: 'Submit a pending PR review. Defaults to COMMENT; use APPROVE or REQUEST_CHANGES to submit with a verdict.',
    inputSchema: {
      owner: z.string().describe('Repository owner'),
      repo: z.string().describe('Repository name'),
      pr_number: z.number().describe('Pull request number'),
      review_id: z.number().describe('ID of the pending review to submit'),
      event: z.enum(['COMMENT', 'APPROVE', 'REQUEST_CHANGES']).default('COMMENT').describe('Review event type'),
    },
  },
  async ({ owner, repo, pr_number, review_id, event }) => {
    const output = execFileSync(
      'gh',
      ['api', `repos/${owner}/${repo}/pulls/${pr_number}/reviews/${review_id}/events`, '--method', 'POST', '--input', '-'],
      { input: JSON.stringify({ event }), encoding: 'utf8' }
    );
    return { content: [{ type: 'text', text: output }] };
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
